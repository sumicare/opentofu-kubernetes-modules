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
  description = "Kubernetes namespace for VPA"
  type        = string
  default     = "vpa"
}

variable "vpa_version" {
  description = "Version of VPA"
  type        = string
  default     = "1.4.1"
}

variable "admission_controller_replicas" {
  description = "Number of replicas for the admission controller deployment"
  type        = number
  default     = 1
}

variable "recommender_replicas" {
  description = "Number of replicas for the recommender deployment"
  type        = number
  default     = 1
}

variable "updater_replicas" {
  description = "Number of replicas for the updater deployment"
  type        = number
  default     = 1
}

variable "admission_controller_resources" {
  description = "Resource requests and limits for the admission controller"
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
      cpu    = "50m"
      memory = "200Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "500Mi"
    }
  }
}

variable "recommender_resources" {
  description = "Resource requests and limits for the recommender"
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
      cpu    = "50m"
      memory = "500Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "1Gi"
    }
  }
}

variable "updater_resources" {
  description = "Resource requests and limits for the updater"
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
      cpu    = "50m"
      memory = "500Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "1Gi"
    }
  }
}

variable "run_as_user" {
  description = "User ID to run the container as"
  type        = number
  default     = 65534
}

variable "revision_history_limit" {
  description = "Number of old ReplicaSets to retain"
  type        = number
  default     = 10
}

variable "pod_recommendation_min_cpu_millicores" {
  description = "Minimum CPU recommendation in millicores"
  type        = number
  default     = 15
}

variable "pod_recommendation_min_memory_mb" {
  description = "Minimum memory recommendation in MB"
  type        = number
  default     = 100
}

variable "webhook_timeout_seconds" {
  description = "Timeout for webhook requests"
  type        = number
  default     = 3
}

variable "liveness_probe_period_seconds" {
  description = "Period for liveness probe"
  type        = number
  default     = 5
}

variable "liveness_probe_timeout_seconds" {
  description = "Timeout for liveness probe"
  type        = number
  default     = 3
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
  default     = 6
}

variable "readiness_probe_failure_threshold" {
  description = "Failure threshold for readiness probe"
  type        = number
  default     = 120
}

variable "cluster_domain" {
  description = "Kubernetes cluster domain"
  type        = string
  default     = "cluster.local"
}

variable "webhook_issuer_name" {
  description = "Name of the cert-manager Issuer to use for webhook certificates"
  type        = string
  default     = null
}

variable "webhook_selfsigned_issuer_name" {
  description = "Name of the cert-manager self-signed Issuer to use for CA certificates"
  type        = string
  default     = null
}
