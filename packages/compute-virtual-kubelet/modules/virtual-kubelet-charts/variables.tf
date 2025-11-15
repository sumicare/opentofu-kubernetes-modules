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
  description = "Kubernetes namespace for KEDA"
  type        = string
  default     = "keda"
}

variable "keda_version" {
  description = "Version of KEDA"
  type        = string
  default     = "2.18.0"
}

variable "operator_replicas" {
  description = "Number of replicas for the operator deployment"
  type        = number
  default     = 3
}

variable "metrics_server_replicas" {
  description = "Number of replicas for the metrics server deployment"
  type        = number
  default     = 1
}

variable "webhook_replicas" {
  description = "Number of replicas for the webhook deployment"
  type        = number
  default     = 1
}

variable "resources" {
  description = "Resource requests and limits for all KEDA containers"
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
      memory = "100Mi"
    }
    limits = {
      cpu    = "1"
      memory = "256Mi"
    }
  }
}

variable "operator_image" {
  description = "Docker image for KEDA operator"
  type        = string
  default     = "ghcr.io/kedacore/keda"
}

variable "metrics_server_image" {
  description = "Docker image for KEDA metrics server"
  type        = string
  default     = "ghcr.io/kedacore/keda-metrics-apiserver"
}

variable "webhook_image" {
  description = "Docker image for KEDA webhook"
  type        = string
  default     = "ghcr.io/kedacore/keda-admission-webhooks"
}

variable "image_pull_policy" {
  description = "Image pull policy for all containers"
  type        = string
  default     = "Always"
}

variable "revision_history_limit" {
  description = "Number of old ReplicaSets to retain"
  type        = number
  default     = 10
}

variable "http_default_timeout" {
  description = "Default HTTP timeout in milliseconds"
  type        = string
  default     = "3000"
}

variable "http_min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS12"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "kubernetes-default"
}

variable "cluster_domain" {
  description = "Kubernetes cluster domain"
  type        = string
  default     = "cluster.local"
}

variable "enable_prometheus_metrics" {
  description = "Enable Prometheus metrics"
  type        = bool
  default     = false
}

variable "liveness_probe_initial_delay" {
  description = "Initial delay for liveness probe"
  type        = number
  default     = 25
}

variable "liveness_probe_timeout" {
  description = "Timeout for liveness probe"
  type        = number
  default     = 1
}

variable "liveness_probe_period" {
  description = "Period for liveness probe"
  type        = number
  default     = 10
}

variable "liveness_probe_success_threshold" {
  description = "Success threshold for liveness probe"
  type        = number
  default     = 1
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for liveness probe"
  type        = number
  default     = 3
}

variable "readiness_probe_initial_delay" {
  description = "Initial delay for readiness probe"
  type        = number
  default     = 20
}

variable "readiness_probe_timeout" {
  description = "Timeout for readiness probe"
  type        = number
  default     = 1
}

variable "readiness_probe_period" {
  description = "Period for readiness probe"
  type        = number
  default     = 3
}

variable "readiness_probe_success_threshold" {
  description = "Success threshold for readiness probe"
  type        = number
  default     = 1
}

variable "readiness_probe_failure_threshold" {
  description = "Failure threshold for readiness probe"
  type        = number
  default     = 3
}

variable "operator_issuer_name" {
  description = "Name of the cert-manager Issuer to use for operator certificates"
  type        = string
  default     = null
}

variable "operator_selfsigned_issuer_name" {
  description = "Name of the cert-manager self-signed Issuer to use for CA certificates"
  type        = string
  default     = null
}
