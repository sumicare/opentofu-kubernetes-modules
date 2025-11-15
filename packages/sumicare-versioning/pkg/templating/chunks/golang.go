//
// Copyright (c) 2025 Sumicare
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package chunks

import "strings"

// ldFlagsVariableInterpolation is the variable interpolation const for ${LD_FLAGS}.
const ldFlagsVariableInterpolation = "${LD_FLAGS}"

// goBinary represents a single binary to build.
type goBinary struct {
	Name    string
	Pkg     string
	LDFlags string
}

// normalizePkg converts package path to build command format.
func normalizePkg(name, pkg string) string {
	if pkg == "" {
		return "./cmd/" + name
	}

	if pkg == "." {
		return "-o " + name + " ."
	}

	return pkg
}

// DockerfileHeader renders the common Dockerfile header with SBOM args and FROM build.
func DockerfileHeader(debianVersion string) string {
	return `ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true
ARG DEBIAN_VERSION="` + debianVersion + `"
ARG REPO="docker.io/"
ARG ORG="sumicare"`
}

// DockerfileBuildHeader renders the common Dockerfile header with SBOM args and FROM build.
func DockerfileBuildHeader(name, debianVersion, version, repo string) string {
	nameUpper := strings.ReplaceAll(strings.ToUpper(name), "-", "_")

	return DockerfileHeader(debianVersion) + `
FROM ${REPO}${ORG}/build:${DEBIAN_VERSION} AS build

ARG TARGETARCH

ARG ` + nameUpper + `_VERSION="` + version + `"
ARG ` + nameUpper + `_REPO="` + repo + `"`
}

// dockerfileBuildEnv renders the build environment setup (HOMEDIR, ADD, WORKDIR).
func dockerfileBuildEnv(name, nameUpper, versionPrefix, workdir string) string {
	return `
ARG HOMEDIR=/build

ARG BUILDER_UID=10000
ARG BUILDER_GID=100

ADD --chown=${BUILDER_UID}:${BUILDER_GID} --keep-git-dir=false ${` + nameUpper + `_REPO}#` + versionPrefix + `${` + nameUpper + `_VERSION} ${HOMEDIR}/` + name + `

WORKDIR ${HOMEDIR}/` + workdir
}

// dockerfileLDFlags renders the LD_FLAGS ARG.
//
//nolint:revive // it's just a template
func dockerfileLDFlags(ldflags string, isStatic bool) string {
	if isStatic {
		return `ARG LD_FLAGS="-s -w -extldflags '-static'` + ldflags + `"`
	}

	return `

ARG LD_FLAGS="-s -w"`
}

// dockerfileVendorCacheStart renders the start of the vendor cache RUN block.
func dockerfileVendorCacheStart(name string) string {
	return `

ENV GOCACHE=${HOMEDIR}/.cache/go-build

RUN --mount=type=cache,id=go-vendor-${TARGETARCH},target=${HOMEDIR}/` + name + `/cached-vendor,uid=${BUILDER_UID},gid=${BUILDER_GID},sharing=locked \
    set -eux ; \
    [ -z "$(ls -A cached-vendor)" ] && go mod vendor && cp -r vendor/* cached-vendor/ ; \
    [ -n "$(ls -A cached-vendor)" ] && mkdir -p vendor && cp -r cached-vendor/* vendor/ ; \
`
}

// dockerfileVendorCacheStartMulti renders vendor cache start for multi-binary builds.
func dockerfileVendorCacheStartMulti(name string) string {
	return `

ENV GOCACHE=${HOMEDIR}/.cache/go-build

RUN --mount=type=cache,id=go-vendor-${TARGETARCH},target=${HOMEDIR}/` + name + `/cached-vendor,uid=${BUILDER_UID},gid=${BUILDER_GID},sharing=locked \
    set -eux ; \
    [ -z "$(ls -A cached-vendor)" ] && go mod vendor && cp -r vendor/* ${HOMEDIR}/cached-vendor/ ; \
    [ -n "$(ls -A cached-vendor)" ] && mkdir -p vendor && cp -r ${HOMEDIR}/cached-vendor/* vendor/ ; \
`
}

// dockerfileVendorCacheEnd renders the cleanup portion of the RUN block.
func dockerfileVendorCacheEnd() string {
	return `    go clean -cache -modcache ; \
    rm -rf vendor ; \
    rm -rf ${HOMEDIR}/.cache ; \
    rm -rf ${GOPATH}/pkg ${GOPATH}/src
`
}

// dockerfileDistrolessStage renders the distroless stage with COPY and ENTRYPOINT.
func dockerfileDistrolessStage(workdir string, binaries []goBinary) string {
	var copyStmts strings.Builder
	for i := range binaries {
		copyStmts.WriteString("COPY --chown=0:0 --from=build ${HOMEDIR}/" + workdir +
			"/" + binaries[i].Name + " /usr/bin/" + binaries[i].Name + "\n")
	}

	return `	
FROM ${REPO}${ORG}/distroless:${DEBIAN_VERSION} AS distroless

ARG HOMEDIR=/build

` + copyStmts.String() + `
USER nonroot

ENTRYPOINT ["/usr/bin/` + binaries[0].Name + `"]`
}

// GoBinaryDockerfile renders common build chunk for a single binary.
func GoBinaryDockerfile(name, debianVersion, version, repo, ldflags, versionPrefix, workdir, pkg string) string {
	nameUpper := strings.ReplaceAll(strings.ToUpper(name), "-", "_")

	prefix := versionPrefix
	if prefix == "" {
		prefix = "v"
	}

	wd := workdir
	if wd == "" {
		wd = name
	}

	pkgToBuild := normalizePkg(name, pkg)

	buildCmd := "    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor -ldflags=\"" + ldFlagsVariableInterpolation + "\" -v " + pkgToBuild + " ; \\\n"
	packCmd := "    upx --best --lzma --exact " + name + " ; \\\n"

	binaries := []goBinary{{Name: name, Pkg: pkgToBuild, LDFlags: ldflags}}

	return DockerfileBuildHeader(name, debianVersion, version, repo) +
		dockerfileBuildEnv(name, nameUpper, prefix, wd) +
		dockerfileLDFlags(ldflags, true) +
		dockerfileVendorCacheStart(name) +
		buildCmd + packCmd +
		dockerfileVendorCacheEnd() +
		dockerfileDistrolessStage(wd, binaries)
}

// parseBinarySpec parses a "name--pkg--ldflags" string into a goBinary.
func parseBinarySpec(spec string) (goBinary, bool) {
	const (
		minParts   = 2
		ldFlagsIdx = 2
	)

	parts := strings.Split(spec, "--")
	if len(parts) < minParts {
		return goBinary{}, false
	}

	name, pkg := parts[0], parts[1]
	ldflags := ldFlagsVariableInterpolation

	if len(parts) > ldFlagsIdx && parts[ldFlagsIdx] != "" {
		ldflags = ldFlagsVariableInterpolation + " " + parts[ldFlagsIdx]
	}

	return goBinary{
		Name:    name,
		Pkg:     normalizePkg(name, pkg),
		LDFlags: ldflags,
	}, true
}

// hasCustomLDFlags checks if any binary has custom ldflags.
func hasCustomLDFlags(binaries []goBinary) bool {
	for i := range binaries {
		if binaries[i].LDFlags != ldFlagsVariableInterpolation {
			return true
		}
	}

	return false
}

// buildMultiBinaryCommands generates build and pack commands for multiple binaries.
func buildMultiBinaryCommands(binaries []goBinary) (string, string) {
	var build, pack strings.Builder

	for i := range binaries {
		build.WriteString("    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor " +
			"-ldflags=\"" + binaries[i].LDFlags + "\" -v -o " + binaries[i].Name + " " + binaries[i].Pkg + " ; \n")
		pack.WriteString("    upx --best --lzma --exact " + binaries[i].Name + " ; \n")
	}

	return build.String(), pack.String()
}

// GoBinariesDockerfile renders common chunk for multiple binaries from a single repo.
// namePkgLDFlags is a set of "name--pkg--ldflags" strings.
func GoBinariesDockerfile(name, debianVersion, version, repo, versionPrefix, workdir string, namePkgLDFlags ...string) string {
	binaries := make([]goBinary, 0, len(namePkgLDFlags))

	for _, spec := range namePkgLDFlags {
		if bin, ok := parseBinarySpec(spec); ok {
			binaries = append(binaries, bin)
		}
	}

	if len(binaries) == 0 {
		return ""
	}

	nameUpper := strings.ReplaceAll(strings.ToUpper(name), "-", "_")

	prefix := versionPrefix
	if prefix == "" {
		prefix = "v"
	}

	wd := workdir
	if wd == "" {
		wd = name
	}

	return DockerfileBuildHeader(name, debianVersion, version, repo) +
		dockerfileBuildEnv(name, nameUpper, prefix, wd) + "\n\n" +
		BuildGoBinariesDockerfile(name, wd, namePkgLDFlags...)
}

// BuildGoBinariesDockerfile renders common chunk for multiple binaries from a single repo.
func BuildGoBinariesDockerfile(name, workdir string, namePkgLDFlags ...string) string {
	binaries := make([]goBinary, 0, len(namePkgLDFlags))

	for _, spec := range namePkgLDFlags {
		if bin, ok := parseBinarySpec(spec); ok {
			binaries = append(binaries, bin)
		}
	}

	if len(binaries) == 0 {
		return ""
	}

	useStaticLDFlags := !hasCustomLDFlags(binaries)
	buildStmts, packStmts := buildMultiBinaryCommands(binaries)

	return dockerfileLDFlags("", useStaticLDFlags) +
		dockerfileVendorCacheStartMulti(name) +
		buildStmts + packStmts +
		dockerfileVendorCacheEnd() +
		dockerfileDistrolessStage(workdir, binaries)
}
