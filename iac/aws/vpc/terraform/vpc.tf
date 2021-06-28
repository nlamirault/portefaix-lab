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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name            = var.vpc_name
  cidr            = var.vpc_subnet_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidr
  public_subnets  = var.public_subnet_cidr

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  reuse_nat_ips       = true
  external_nat_ip_ids = data.aws_eip.igw.*.id

  #enable_ecr_api_endpoint              = true
  #ecr_api_endpoint_private_dns_enabled = true
  #ecr_api_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  #enable_kms_endpoint              = true
  #kms_endpoint_private_dns_enabled = true
  #kms_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  #enable_lambda_endpoint              = true
  #lambda_endpoint_private_dns_enabled = true
  #lambda_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  tags = merge({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared",
  }, var.vpc_tags)

  public_subnet_tags = merge({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }, var.public_subnet_tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }, var.private_subnet_tags)

}
