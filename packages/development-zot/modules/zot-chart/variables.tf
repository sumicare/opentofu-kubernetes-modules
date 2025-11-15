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
  description = "Kubernetes namespace for Zot"
  type        = string
  default     = "zot"
}

variable "zot_version" {
  description = "Version of Zot"
  type        = string
  default     = "v2.1.10"
}

variable "replicas" {
  description = "Number of replicas for the statefulset"
  type        = number
  default     = 1
}

variable "image" {
  description = "Container image for Zot"
  type        = string
  default     = "ghcr.io/project-zot/zot"
}

variable "http_port" {
  description = "HTTP port for Zot"
  type        = number
  default     = 5000
}

variable "storage_size" {
  description = "Storage size for persistent volume"
  type        = string
  default     = "8Gi"
}

variable "storage_class_name" {
  description = "Storage class name for persistent volume"
  type        = string
  default     = null
}

variable "resources" {
  description = "Resource requests and limits for the container"
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
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
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
  default     = 10
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
  default     = 3
}

variable "readiness_probe_initial_delay" {
  description = "Initial delay for readiness probe"
  type        = number
  default     = 5
}

variable "readiness_probe_timeout" {
  description = "Timeout for readiness probe"
  type        = number
  default     = 5
}

variable "readiness_probe_period" {
  description = "Period for readiness probe"
  type        = number
  default     = 10
}

variable "readiness_probe_failure_threshold" {
  description = "Failure threshold for readiness probe"
  type        = number
  default     = 3
}

variable "startup_probe_initial_delay" {
  description = "Initial delay for startup probe"
  type        = number
  default     = 5
}

variable "startup_probe_timeout" {
  description = "Timeout for startup probe"
  type        = number
  default     = 5
}

variable "startup_probe_period" {
  description = "Period for startup probe"
  type        = number
  default     = 10
}

variable "startup_probe_failure_threshold" {
  description = "Failure threshold for startup probe"
  type        = number
  default     = 3
}

variable "termination_grace_period_seconds" {
  description = "Termination grace period in seconds"
  type        = number
  default     = 30
}

variable "security_context_fs_group" {
  description = "FSGroup for pod security context"
  type        = number
  default     = 1000
}

variable "security_context_run_as_user" {
  description = "Run as user ID for security context"
  type        = number
  default     = 1000
}

variable "revision_history_limit" {
  description = "Revision history limit for statefulset"
  type        = number
  default     = 10
}

variable "rollout_percentage" {
  description = "Percentage of pods to update during rolling update (0-100)"
  type        = number
  default     = 25
  validation {
    condition     = var.rollout_percentage >= 0 && var.rollout_percentage <= 100
    error_message = "rollout_percentage must be between 0 and 100"
  }
}
