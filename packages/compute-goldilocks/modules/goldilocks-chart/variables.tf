/*
   Copyright 2025 Sumicare

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


variable "org" {
  description = "Organization Name"
  type        = string
  default     = "sumicare"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of dev, staging, or prod"
  }
}

variable "namespace" {
  description = "Kubernetes namespace for Goldilocks"
  type        = string
  default     = "goldilocks"
}

variable "goldilocks_version" {
  description = "Version of Goldilocks"
  type        = string
  default     = "v4.14.1"
}

variable "controller_replicas" {
  description = "Number of replicas for the controller deployment"
  type        = number
  default     = 1
}

variable "dashboard_replicas" {
  description = "Number of replicas for the dashboard deployment"
  type        = number
  default     = 2
}

variable "resources" {
  description = "Resource requests and limits for the containers"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "25m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "100m"
      memory = "512Mi"
    }
  }
}

variable "run_as_user" {
  description = "User ID to run the container as"
  type        = number
  default     = 10324
}

variable "on_by_default" {
  description = "Enable Goldilocks on all namespaces by default"
  type        = bool
  default     = true
}

variable "exclude_containers" {
  description = "Containers to exclude from recommendations"
  type        = string
  default     = "linkerd-proxy,istio-proxy"
}

variable "revision_history_limit" {
  description = "Number of old ReplicaSets to retain"
  type        = number
  default     = 10
}

variable "dashboard_service_port" {
  description = "Port for the dashboard service"
  type        = number
  default     = 80
}

variable "dashboard_container_port" {
  description = "Port for the dashboard container"
  type        = number
  default     = 8080
}

variable "fs_group" {
  description = "Filesystem group ID for pod volumes"
  type        = number
  default     = 10324
}

variable "liveness_probe_initial_delay" {
  description = "Initial delay for liveness probe"
  type        = number
  default     = 5
}

variable "liveness_probe_timeout" {
  description = "Timeout for liveness probe"
  type        = number
  default     = 5
}

variable "liveness_probe_period" {
  description = "Period for liveness probe"
  type        = number
  default     = 20
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
  default     = 3
}
