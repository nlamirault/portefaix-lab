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

project = "portefaix-prod"

region = "europe-west1"

##############################################################################
# VPC

network_name = "portefaix-prod"


###########################################################################
# Kubernetes cluster

location = "europe-west1-c"

name = "portefaix-prod-cluster-gke"

release_channel = "REGULAR"

network_config = {
  enable_natgw   = true
  enable_ssh     = false
  private_master = false
  private_nodes  = true
  pods_cidr      = "portefaix-prod-gke-pods"
  services_cidr  = "portefaix-prod-gke-services"
}

master_ipv4_cidr_block = "10.0.63.0/28"

# bastion_external_ip_name = "portefaix-prod-external-ip-bastion"
# nat_external_ip_0_name = "portefaix-prod-external-ip-nat-0"
# nat_external_ip_1_name = "portefaix-prod-external-ip-nat-1"

# master_authorized_networks = [
#   # Example :
#     {
#       cidr_block   = "0.0.0.0/0"
#       display_name = "internet"
#     }
# ]

labels = {
  env     = "prod"
  service = "kubernetes"
  made-by = "terraform"
}

network_policy             = false
auto_scaling               = false
hpa                        = true
pod_security_policy        = false
shielded_nodes             = true
monitoring_service         = true
logging_service            = true
binary_authorization       = false
google_cloud_load_balancer = true
istio                      = false
cloudrun                   = false
csi_driver                 = true
dns_cache                  = true
datapath_provider          = "ADVANCED_DATAPATH"
config_connector           = true

maintenance_start_time = "01:00"

default_max_pods_per_node = 32

###########################################################################
# Kubernetes node pool

node_labels = {
  env     = "prod"
  service = "kubernetes"
  made-by = "terraform"
}

node_tags = ["kubernetes", "nodes"]

auto_upgrade = true
auto_repair  = true

#############################################################################
# Addons node pools

node_pools = [
  {
    name                    = "core"
    node_count              = 2
    autoscaling             = true
    min_node_count          = 0
    max_node_count          = 3
    machine_type            = "e2-standard-8"
    disk_size_gb            = 100
    max_pods_per_node       = 110
    preemptible             = true
    default_service_account = false
    taints                  = []
  },
  {
    name                    = "ops"
    node_count              = 0
    autoscaling             = true
    min_node_count          = 0
    max_node_count          = 1
    machine_type            = "e2-standard-4"
    disk_size_gb            = 100
    max_pods_per_node       = 110
    preemptible             = true
    default_service_account = false
    taints = [
      {
        key    = "role"
        value  = "ops"
        effect = "NO_SCHEDULE"
      }
    ]
  }
]
