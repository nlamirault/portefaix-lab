# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>
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

#############################################################################
# Provider

resource_group_name = "portefaix-dev"

#############################################################################
# Sops

aks_resource_group_name = "portefaix-dev"
cluster_name            = "portefaix-dev-aks"

sops_resource_group_name     = "sops-dev"
sops_resource_group_location = "West Europe"

tags = {
    "made-by" = "terraform"
    "service" = "sops"
    "project" = "portefaix"
    "env"     = "dev"
}