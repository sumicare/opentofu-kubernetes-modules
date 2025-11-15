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

{{ GeneratedCommentStub }}

{{ DockerfileBuildHeader "zot" "development-zot" }}

ARG HOMEDIR=/build

ARG BUILDER_UID=10000
ARG BUILDER_GID=100

ADD --chown=${BUILDER_UID}:${BUILDER_GID} --keep-git-dir=false ${ZOT_REPO}#v${ZOT_VERSION} ${HOMEDIR}/zot

WORKDIR ${HOMEDIR}/zot

ARG LD_FLAGS="-s -w -extldflags '-static'"

ENV GOCACHE=${HOMEDIR}/.cache/go-build

RUN --mount=type=cache,id=go-vendor-${TARGETARCH},target=${HOMEDIR}/zot/cached-vendor,uid=${BUILDER_UID},gid=${BUILDER_GID},sharing=locked \
    set -eux ; \
    [ -z "$(ls -A cached-vendor)" ] && go mod vendor && cp -r vendor/* cached-vendor/ ; \
    [ -n "$(ls -A cached-vendor)" ] && mkdir -p vendor && cp -r cached-vendor/* vendor/ ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/oci.proto=./gen' \
    --go_opt='Mmeta/meta.proto=./gen' \
    --go_opt='Moci/config.proto=./gen' \
    --go_opt='Moci/manifest.proto=./gen' \
    --go_opt='Moci/index.proto=./gen' \
    --go_opt='Moci/descriptor.proto=./gen' \
    --go_opt='Moci/versioned.proto=./gen' \
    ./pkg/meta/proto/meta/meta.proto ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/versioned.proto=./gen' \
    ./pkg/meta/proto/oci/versioned.proto ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/descriptor.proto=./gen' \
    ./pkg/meta/proto/oci/descriptor.proto ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/descriptor.proto=./gen' \
    --go_opt='Moci/versioned.proto=./gen' \
    --go_opt='Moci/index.proto=./gen' \
    ./pkg/meta/proto/oci/index.proto ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/oci.proto=./gen' \
    --go_opt='Moci/descriptor.proto=./gen' \
    --go_opt='Moci/config.proto=./gen' \
    ./pkg/meta/proto/oci/config.proto ; \
    protoc --experimental_allow_proto3_optional \
    --proto_path=./pkg/meta/proto \
    --go_out=./pkg/meta/proto \
    --go_opt='Moci/versioned.proto=./gen' \
    --go_opt='Moci/descriptor.proto=./gen' \
    --go_opt='Moci/manifest.proto=./gen' \
    ./pkg/meta/proto/oci/manifest.proto ; \
    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor -ldflags="${LD_FLAGS}" -v -o zb ./cmd/zb ; \
    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor -ldflags="${LD_FLAGS}" -v -o zot ./cmd/zot ; \
    GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -mod=vendor -ldflags="${LD_FLAGS}" -v -o zxp ./cmd/zxp ; \
    upx --best --lzma --exact zb ; \ 
    upx --best --lzma --exact zot ; \ 
    upx --best --lzma --exact zxp ; \
    go clean -cache -modcache ; \
    rm -rf vendor ; \
    rm -rf ${HOMEDIR}/.cache ; \
    rm -rf ${GOPATH}/pkg ${GOPATH}/src  

FROM ${REPO}${ORG}/distroless:${DEBIAN_VERSION} AS distroless

ARG HOMEDIR=/build

COPY --chown=0:0 --from=build ${HOMEDIR}/zot/zb /usr/bin/zb
COPY --chown=0:0 --from=build ${HOMEDIR}/zot/zot /usr/bin/zot
COPY --chown=0:0 --from=build ${HOMEDIR}/zot/zxp /usr/bin/zxp

ENTRYPOINT ["/usr/bin/zot"]
