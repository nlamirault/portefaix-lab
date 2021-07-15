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

resource "google_secret_manager_secret" "thanos_config" {
  secret_id = "thanos_configuration"

  labels = var.thanos_secret_labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "thanos_config" {
  secret      = google_secret_manager_secret.thanos_config.id
  secret_data = file(var.thanos_secret_config)
}

resource "google_secret_manager_secret" "loki_config" {
  secret_id = "loki_configuration"

  labels = var.loki_secret_labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "loki_config" {
  secret      = google_secret_manager_secret.loki_config.id
  secret_data = file(var.loki_secret_config)
}

resource "google_secret_manager_secret" "tempo_config" {
  secret_id = "tempo_configuration"

  labels = var.tempo_secret_labels

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "tempo_config" {
  secret      = google_secret_manager_secret.tempo_config.id
  secret_data = file(var.tempo_secret_config)
}
