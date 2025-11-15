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
  description = "Kubernetes namespace for OpenCost"
  type        = string
  default     = "opencost"
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 3
}

variable "opencost_version" {
  description = "Version of OpenCost"
  type        = string
  default     = "1.117.6"
}

variable "opencost_image" {
  description = "Container image for OpenCost"
  type        = string
  default     = "ghcr.io/opencost/opencost"
}

variable "opencost_ui_image" {
  description = "Container image for OpenCost UI"
  type        = string
  default     = "ghcr.io/opencost/opencost-ui"
}

variable "opencost_image_digest" {
  description = "Image digest for OpenCost"
  type        = string
  default     = "sha256:6f1a0e6fe21559a77051e7b7f9e4ac6bc80277131492ae084e8365ada805af91"
}

variable "opencost_ui_image_digest" {
  description = "Image digest for OpenCost UI"
  type        = string
  default     = "sha256:fd26f004b2b2565e22240fc2a9f6adb078fdb4de3fc1a1b16c611a3c3b80683e"
}

variable "resources_opencost" {
  description = "Resource requests and limits for OpenCost container"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "10m"
      memory = "55Mi"
    }
    limits = {
      memory = "1Gi"
    }
  }
}

variable "resources_ui" {
  description = "Resource requests and limits for OpenCost UI container"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "10m"
      memory = "55Mi"
    }
    limits = {
      memory = "1Gi"
    }
  }
}

variable "run_as_user" {
  description = "User ID to run the container as"
  type        = number
  default     = 1000
}

variable "fs_group" {
  description = "Filesystem group ID for pod volumes"
  type        = number
  default     = 2000
}

variable "log_level" {
  description = "Log level for OpenCost"
  type        = string
  default     = "info"
}

variable "custom_cost_enabled" {
  description = "Enable custom cost metrics"
  type        = bool
  default     = false
}

variable "prometheus_server_endpoint" {
  description = "Prometheus server endpoint URL"
  type        = string
  default     = "http://prometheus-server.prometheus-system.svc.cluster.local:80"
}

variable "prometheus_namespace" {
  description = "Namespace where Prometheus is deployed"
  type        = string
  default     = "prometheus-system"
}

variable "prometheus_query_resolution_seconds" {
  description = "Prometheus query resolution in seconds"
  type        = number
  default     = 300
}

variable "cluster_id" {
  description = "Cluster identifier"
  type        = string
  default     = "default-cluster"
}

variable "insecure_skip_verify" {
  description = "Skip TLS verification"
  type        = bool
  default     = false
}

variable "cloud_cost_enabled" {
  description = "Enable cloud cost integration"
  type        = bool
  default     = false
}

variable "cloud_cost_month_to_date_interval" {
  description = "Cloud cost month-to-date interval in hours"
  type        = number
  default     = 6
}

variable "cloud_cost_refresh_rate_hours" {
  description = "Cloud cost refresh rate in hours"
  type        = number
  default     = 6
}

variable "cloud_cost_query_window_days" {
  description = "Cloud cost query window in days"
  type        = number
  default     = 7
}

variable "cloud_cost_run_window_days" {
  description = "Cloud cost run window in days"
  type        = number
  default     = 3
}

variable "resolution_1d_retention" {
  description = "Retention period for 1-day resolution data"
  type        = number
  default     = 15
}

variable "resolution_1h_retention" {
  description = "Retention period for 1-hour resolution data"
  type        = number
  default     = 49
}

variable "api_port" {
  description = "API port for OpenCost"
  type        = number
  default     = 9003
}

variable "ui_port" {
  description = "UI port for OpenCost"
  type        = number
  default     = 9090
}

variable "liveness_probe_initial_delay" {
  description = "Initial delay for liveness probe"
  type        = number
  default     = 10
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

variable "readiness_probe_initial_delay" {
  description = "Initial delay for readiness probe"
  type        = number
  default     = 10
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
  default     = 10
}

variable "startup_probe_period" {
  description = "Period for startup probe"
  type        = number
  default     = 5
}

variable "startup_probe_failure_threshold" {
  description = "Failure threshold for startup probe"
  type        = number
  default     = 30
}

variable "ui_liveness_probe_initial_delay" {
  description = "Initial delay for UI liveness probe"
  type        = number
  default     = 30
}

variable "ui_liveness_probe_period" {
  description = "Period for UI liveness probe"
  type        = number
  default     = 10
}

variable "ui_liveness_probe_failure_threshold" {
  description = "Failure threshold for UI liveness probe"
  type        = number
  default     = 3
}

variable "ui_readiness_probe_initial_delay" {
  description = "Initial delay for UI readiness probe"
  type        = number
  default     = 30
}

variable "ui_readiness_probe_period" {
  description = "Period for UI readiness probe"
  type        = number
  default     = 10
}

variable "ui_readiness_probe_failure_threshold" {
  description = "Failure threshold for UI readiness probe"
  type        = number
  default     = 3
}

variable "pdb_min_available" {
  description = "Minimum available pods for PDB"
  type        = string
  default     = "1"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for cloud integration"
  type        = string
  default     = "access-key-id"
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for cloud integration"
  type        = string
  default     = "secret-access-key"
  sensitive   = true
}
