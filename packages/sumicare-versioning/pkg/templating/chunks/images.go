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

const (
	// newNewLine is a constant for a double newline.
	newNewLine = "\n\n"
)

// ImageProviders is the Terraform required_providers block for Docker images.
func ImageProviders() string {
	return `terraform {
  required_version = ">= 1.10"

  required_providers {
    docker = {
      source  = "registry.opentofu.org/kreuzwerker/docker"
      version = "~> 3"
    }
  }
}`
}

// OrgRepoStub org repository settings for the images and charts.
func OrgRepoStub() string {
	return `variable "org" {
  description = "Organization Name, used for image tagging."
  type        = string
  default     = "sumicare"
}

variable "repository" {
  description = "Image repository path, with trailing '/'."
  type        = string
  default     = "docker.io/"
}`
}

// EnvStub environment variable for charts.
func EnvStub() string {
	return `variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Env must be one of dev, staging, or prod."
  }
}`
}

// DebianVersionVariable debian version tf variable.
func DebianVersionVariable(debianVersion string) string {
	return `variable "debian_version" {
  description = "Debian Version to build distroless image from."
  type        = string
  default     = "` + debianVersion + `"
}`
}

// RegistryAuthVariable docker registry auth tf variable.
func RegistryAuthVariable() string {
	return `variable "registry_auth" {
  description = "Docker registry auth configuration, to push images into."
  type = object({
    address  = string
    username = string
    password = string
  })
  default = null
}`
}

// ChartVariablesStub are common terraform variables shared across all terraform chart modules.
func ChartVariablesStub() string {
	return GeneratedCommentStub() + newNewLine + OrgRepoStub() + newNewLine + EnvStub()
}

// ImageVariablesStub are common terraform variables shared across all terraform image modules.
func ImageVariablesStub(debianVersion string) string {
	return GeneratedCommentStub() + newNewLine + OrgRepoStub() + newNewLine + RegistryAuthVariable() + newNewLine + DebianVersionVariable(debianVersion)
}

// snakeToCamelCase converts snake_case to CamelCase.
func snakeToCamelCase(s string) string {
	parts := strings.Split(s, "_")
	for i, part := range parts {
		if part != "" {
			parts[i] = strings.ToUpper(string(part[0])) + part[1:]
		}
	}

	return strings.Join(parts, "")
}

// DockerImageResources generates Terraform Docker Image and Registry Image to build and push the respective image.
func DockerImageResources(name string) string {
	camelCase := snakeToCamelCase(name)
	allUpper := strings.ToUpper(strings.ReplaceAll(name, "-", "_"))

	return `resource "docker_image" "` + name + `" {
  name         = "${var.repository}${var.org}/` + name + `:${var.` + name + `_version}` + `"
  keep_locally = true
  triggers = {
    Dockerfile         = filesha256("${path.module}/Dockerfile")
    DebianVersion      = var.debian_version
    ` + camelCase + `Version = var.` + name + `_version
  }

  build {
    context    = path.module
    builder    = "default"
    dockerfile = "${path.module}/Dockerfile"
    tag        = ["${var.repository}${var.org}/` + name + `:${var.` + name + `_version}` + `"]
    build_args = {
      REPO : var.repository
      ORG : var.org
      DEBIAN_VERSION : var.debian_version
      ` + allUpper + `_VERSION : var.` + name + `_version
    }
    label = {
      author : var.org
    }
  }
}

resource "docker_registry_image" "` + name + `" {
  count         = var.registry_auth == null ? 0 : 1
  name          = docker_image.` + name + `.name
  keep_remotely = true

  dynamic "auth_config" {
    for_each = var.registry_auth == null ? [] : [var.registry_auth]
    content {
      address  = auth_config.value.address
      username = auth_config.value.username
      password = auth_config.value.password
    }
  }

  depends_on = [docker_image.` + name + `]
}`
}

// DockerImageDigestOutput generates a Terraform output for the image digest of the specified image.
func DockerImageDigestOutput(name string) string {
	return `output "` + name + `_image_digest" {
  value       = trimprefix("${var.org}/` + name + `@sha256:", docker_image.` + name + `.repo_digest)
  description = "` + name + ` image digest"
}`
}
