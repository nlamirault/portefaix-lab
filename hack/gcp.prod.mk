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

GCP_PROJECT_prod = portefaix-prod

GCP_REGION_prod = europe-west1-c

CLUSTER_prod = portefaix-prod-cluster-gke

KUBE_CONTEXT_prod = gke_portefaix-prod_europe-west1-c_portefaix-prod-cluster-gke

# SOPS_PROVIDER_prod = gcp-kms
# SOPS_KEY_prod = projects/portefaix-prod/locations/europe-west1/keyRings/portefaix-prod-sops/cryptoKeys/portefaix-prod-sops
SOPS_PROVIDER_prod = age
SOPS_KEY_prod = age177h9wx48t7cu3ycnyf6qzjavwlsdwclz4wj7n8u8uj7k8tthjv8q00kggc
SOPS_AGE_KEY_FILE_prod = .secrets/$(CLOUD)/$(ENV)/age/age.agekey
