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

// DistrolessUnpack returns common Debian distroless dockerfile unpack chunk.
func DistrolessUnpack() string {
	return `RUN --mount=type=cache,id=cache-apt-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=lib-apt-${TARGETARCH},target=/var/lib/apt,sharing=locked \
    set -eux ; \
    # Download and extract packages
    apt-get update -y ; \
    apt-get upgrade -y ; \
    echo ${DISTROLESS_PACKAGES} | xargs apt-get download -y --no-install-recommends --no-install-suggests ; \
    mkdir -p /dpkg/var/lib/dpkg/status.d/ ; \
    for deb in *.deb; do \
    package_name="$(dpkg-deb -I "${deb}" | awk '/^ Package: .*$/ {print $2}')" ; \
    echo "Processing: ${package_name}" ; \
    dpkg --ctrl-tarfile "$deb" | tar -Oxf - ./control > "/dpkg/var/lib/dpkg/status.d/${package_name}" ; \
    dpkg --extract "$deb" /dpkg || exit 10 ; \
    done ; \
    # Cleanup
    find /dpkg/ -type d -empty -delete ; \
    rm -rf /dpkg/usr/share/doc/ ; \
    apt-get purge -y --auto-remove ; \
    find /usr -name '*.pyc' -type f -exec bash -c 'for pyc; do dpkg -S "$pyc" &> /dev/null || rm -vf "$pyc"; done' -- '{}' + ; \
    rm -rf /var/lib/apt/lists/* `
}
