# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>

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

# Documentation:
# https://docs.microsoft.com/en-us/rest/api/aks/managedclusters/get

resource_group = attribute('resourcegroup', description:'Azure resource group')
location = attribute('location', description:'Azure location')
sa_name = attribute("sa_name")

control "velero-1" do
  impact 1.0

  title "Ensure resource group exists"

  tag platform: "Azure"
  tag category: 'ResourceGroup'
  tag resource: "Velero"
  tag effort: 0.2

  describe azure_resource_group(name: resource_group) do
    it { should exist }
    its('tags') { should include(project: 'portefaix') }
    its('tags') { should include(service: 'velero') }
    its('tags') { should include(env: 'dev') }
    its('tags') { should include("made-by": 'terraform') }
  end
end


control "velero-2" do
  impact 0.9

  title "Ensure storage account exists"

  tag platform: "Azure"
  tag category: 'Storage'
  tag resource: "Velero"
  tag effort: 0.2

  describe azure_storage_account(resource_group: resource_group, name: sa_name)  do
    it { should exist }
    it { should have_encryption_enabled }
  end

end
