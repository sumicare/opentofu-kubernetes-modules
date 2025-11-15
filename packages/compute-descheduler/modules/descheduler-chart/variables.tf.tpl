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

{{ ChartVariablesStub }}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 3
}

variable "deploy_custom_resources" {
  description = "Deploy custom resources"
  type        = bool
  default     = true
}

variable "monitoring_namespace" {
  description = "Namespace for observability custom resources"
  type        = string
  default     = "monitoring"
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
      cpu    = "500m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "256Mi"
    }
  }
}

variable "descheduling_interval" {
  description = "Interval for descheduling runs"
  type        = string
  default     = "2m"
}

variable "log_level" {
  description = "Log level (verbosity)"
  type        = number
  default     = 3
}

variable "leader_elect_lease_duration" {
  description = "Leader election lease duration"
  type        = string
  default     = "15s"
}

variable "leader_elect_renew_deadline" {
  description = "Leader election renew deadline"
  type        = string
  default     = "10s"
}

variable "leader_elect_retry_period" {
  description = "Leader election retry period"
  type        = string
  default     = "2s"
}

variable "run_as_user" {
  description = "User ID to run the container as"
  type        = number
  default     = 1000
}

variable "fs_group" {
  description = "Filesystem group ID for pod volumes"
  type        = number
  default     = 1000
}

variable "http_metrics_port" {
  description = "Port for HTTP metrics endpoint"
  type        = number
  default     = 10258
}

variable "probe_initial_delay" {
  description = "Initial delay for liveness/readiness probes"
  type        = number
  default     = 5
}

variable "probe_timeout" {
  description = "Timeout for liveness/readiness probes"
  type        = number
  default     = 5
}

variable "probe_period" {
  description = "Period for liveness/readiness probes"
  type        = number
  default     = 20
}

variable "probe_failure_threshold" {
  description = "Failure threshold for liveness/readiness probes"
  type        = number
  default     = 3
}



variable "descheduler_version" {
  description = "Version of Descheduler"
  type        = string
  default     = "{{index .Versions "compute-descheduler"}}"
}

variable "image" {
  description = "Container image for Descheduler"
  type        = string
  default     = "docker.io/sumicare/descheduler"
}
