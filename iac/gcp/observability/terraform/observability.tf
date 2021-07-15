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

module "prometheus" {
  source  = "nlamirault/observability/google//modules/prometheus"
  version = "4.2.0"

  project = var.project

  namespace       = var.prometheus_namespace
  service_account = var.prometheus_service_account
}

module "thanos" {
  source  = "nlamirault/observability/google//modules/thanos"
  version = "4.2.0"

  project = var.project

  bucket_location      = var.thanos_bucket_location
  bucket_storage_class = var.thanos_bucket_storage_class
  bucket_labels        = var.thanos_bucket_labels

  namespace                  = var.thanos_namespace
  service_account            = var.thanos_service_account
  prometheus_service_account = var.thanos_sidecar_service_account

  enable_kms       = var.thanos_enable_kms
  keyring_location = var.thanos_keyring_location

  depends_on = [module.prometheus]
}

module "loki" {
  source  = "nlamirault/observability/google//modules/loki"
  version = "4.2.0"

  project = var.project

  bucket_location      = var.loki_bucket_location
  bucket_storage_class = var.loki_bucket_storage_class
  bucket_labels        = var.loki_bucket_labels

  namespace       = var.loki_namespace
  service_account = var.loki_service_account

  enable_kms       = var.loki_enable_kms
  keyring_location = var.loki_keyring_location
}

module "tempo" {
  source  = "nlamirault/observability/google//modules/tempo/"
  version = "4.2.0"

  project = var.project

  bucket_location      = var.tempo_bucket_location
  bucket_storage_class = var.tempo_bucket_storage_class
  bucket_labels        = var.tempo_bucket_labels

  namespace       = var.tempo_namespace
  service_account = var.tempo_service_account

  enable_kms       = var.tempo_enable_kms
  keyring_location = var.tempo_keyring_location
}

module "grafana" {
  source  = "nlamirault/observability/google//modules/grafana/"
  version = "4.2.0"

  project = var.project

  namespace       = var.grafana_namespace
  service_account = var.grafana_service_account
}
