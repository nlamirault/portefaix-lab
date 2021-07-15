# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

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

resource_group = attribute('resourcegroup', description:'Azure resource group')
nat_gw_ip_1 = attribute('nat_gw_ip_1')
nat_gw_ip_2 = attribute('nat_gw_ip_2')


control "ip-nat-gw-1" do
  impact 1.0

  title "Ensure Nat Gateway public IP exists"

  tag platform: "Azure"
  tag category: 'PublicIP'
  tag resource: "NatGateway"
  tag effort: 0.2

  describe azure_public_ip(resource_group: resource_group, name: nat_gw_ip_1) do
    it { should exist }
  end

  describe azure_public_ip(resource_group: resource_group, name: nat_gw_ip_2) do
    it { should exist }
  end

end
