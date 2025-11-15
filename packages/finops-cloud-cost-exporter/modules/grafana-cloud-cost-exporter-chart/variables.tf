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
  description = "Kubernetes namespace for CloudCost Exporter"
  type        = string
  default     = "finops"
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 3
}

variable "cloudcost_exporter_version" {
  description = "Version of CloudCost Exporter"
  type        = string
  default     = "0.10.0"
}

variable "image" {
  description = "Container image for CloudCost Exporter"
  type        = string
  default     = "grafana/cloudcost-exporter"
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
      cpu    = "1"
      memory = "1Gi"
    }
    limits = {
      cpu    = "2"
      memory = "2Gi"
    }
  }
}

variable "http_port" {
  description = "Port for HTTP endpoint"
  type        = number
  default     = 8080
}

variable "fs_group" {
  description = "Filesystem group ID for pod volumes"
  type        = number
  default     = 10001
}

variable "min_ready_seconds" {
  description = "Minimum number of seconds for which a newly created pod should be ready"
  type        = number
  default     = 10
}

variable "revision_history_limit" {
  description = "Number of old ReplicaSets to retain"
  type        = number
  default     = 10
}
