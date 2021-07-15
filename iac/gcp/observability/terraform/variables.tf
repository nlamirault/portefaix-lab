# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#####################################################################""
# Provider

variable "project" {
  type        = string
  description = "The project in which the resource belongs"
}

variable "region" {
  type        = string
  description = "The location linked to the project"
}

############################################################################
# Obervability

# Prometheus

variable "prometheus_namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "prometheus_service_account" {
  type        = string
  description = "The Kubernetes service account"
}

# Thanos

variable "thanos_bucket_location" {
  type        = string
  description = "The bucket location"
}

variable "thanos_bucket_storage_class" {
  type        = string
  description = "Bucket storage class."
  default     = "MULTI_REGIONAL"
}

variable "thanos_bucket_labels" {
  description = "Map of labels to apply to the bucket"
  type        = map(string)
}

variable "thanos_namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "thanos_service_account" {
  type        = list(string)
  description = "The Kubernetes service account"
}

variable "thanos_sidecar_service_account" {
  type        = string
  description = "The Google service account ID of Prometheus"
}

variable "thanos_enable_kms" {
  type        = bool
  description = "Enable custom KMS key"
}

variable "thanos_keyring_location" {
  type        = string
  description = "The KMS keyring location"
}

variable "thanos_secret_config" {
  type        = string
  description = "Thanos configuration"
}

variable "thanos_secret_labels" {
  description = "Map of labels to apply to the secret"
  type        = map(string)
}

# Loki

variable "loki_bucket_location" {
  type        = string
  description = "The bucket location"
}

variable "loki_bucket_storage_class" {
  type        = string
  description = "Bucket storage class."
  default     = "MULTI_REGIONAL"
}

variable "loki_bucket_labels" {
  description = "Map of labels to apply to the bucket"
  type        = map(string)
}

variable "loki_namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "loki_service_account" {
  type        = string
  description = "The Kubernetes service account"
}

variable "loki_enable_kms" {
  type        = bool
  description = "Enable custom KMS key"
}

variable "loki_keyring_location" {
  type        = string
  description = "The KMS keyring location"
}

variable "loki_secret_config" {
  type        = string
  description = "Loki configuration"
}

variable "loki_secret_labels" {
  description = "Map of labels to apply to the secret"
  type        = map(string)
}

# Tempo

variable "tempo_bucket_location" {
  type        = string
  description = "The bucket location"
}

variable "tempo_bucket_storage_class" {
  type        = string
  description = "Bucket storage class."
  default     = "MULTI_REGIONAL"
}

variable "tempo_bucket_labels" {
  description = "Map of labels to apply to the bucket"
  type        = map(string)
}

variable "tempo_namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "tempo_service_account" {
  type        = string
  description = "The Kubernetes service account"
}

variable "tempo_enable_kms" {
  type        = bool
  description = "Enable custom KMS key"
}

variable "tempo_keyring_location" {
  type        = string
  description = "The KMS keyring location"
}

variable "tempo_secret_config" {
  type        = string
  description = "Tempo configuration"
}

variable "tempo_secret_labels" {
  description = "Map of labels to apply to the secret"
  type        = map(string)
}

# Grafana

variable "grafana_namespace" {
  type        = string
  description = "The Kubernetes namespace"
}

variable "grafana_service_account" {
  type        = string
  description = "The Kubernetes service account"
}
