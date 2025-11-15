# syntax=docker/dockerfile:1
# escape=\

#
# Copyright 2025 Sumicare
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###           DO NOT EDIT            ###
# This file is automagically generated #

ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true
ARG DEBIAN_VERSION="trixie-20251117-slim"
ARG REPO="docker.io/"
ARG ORG="sumicare"
FROM ${REPO}${ORG}/build:${DEBIAN_VERSION} AS build

ARG TARGETARCH

ARG NODE_EXPORTER_VERSION="1.10.2"
ARG NODE_EXPORTER_REPO="https://github.com/prometheus/node_exporter.git"
ARG HOMEDIR=/build

ARG BUILDER_UID=10000
ARG BUILDER_GID=100

ADD --chown=${BUILDER_UID}:${BUILDER_GID} --keep-git-dir=false ${NODE_EXPORTER_REPO}#v${NODE_EXPORTER_VERSION} ${HOMEDIR}/node_exporter

WORKDIR ${HOMEDIR}/node_exporterARG LD_FLAGS="-s -w -extldflags '-static'"

ENV GOCACHE=${HOMEDIR}/.cache/go-build

RUN --mount=type=cache,id=go-vendor-${TARGETARCH},target=${HOMEDIR}/node_exporter/cached-vendor,uid=${BUILDER_UID},gid=${BUILDER_GID},sharing=locked \
    set -eux ; \
    [ -z "$(ls -A cached-vendor)" ] && go mod vendor && cp -r vendor/* cached-vendor/ ; \
    [ -n "$(ls -A cached-vendor)" ] && mkdir -p vendor && cp -r cached-vendor/* vendor/ ; \
    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor -ldflags="${LD_FLAGS}" -v -o node_exporter ./cmd ; \
    upx --best --lzma --exact node_exporter ; \
    go clean -cache -modcache ; \
    rm -rf vendor ; \
    rm -rf ${HOMEDIR}/.cache ; \
    rm -rf ${GOPATH}/pkg ${GOPATH}/src
	
FROM ${REPO}${ORG}/distroless:${DEBIAN_VERSION} AS distroless

ARG HOMEDIR=/build

COPY --chown=0:0 --from=build ${HOMEDIR}/node_exporter/node_exporter /usr/bin/node_exporter

USER nonroot

ENTRYPOINT ["/usr/bin/node_exporter"]
