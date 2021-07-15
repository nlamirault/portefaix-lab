#!/usr/bin/env bash

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

manifest=$1

[ -z "${manifest}" ] && echo "HelmRelease file not satisfied" && exit 1

CHART_REPO_URL=$(grep registryUrl "${manifest}" | awk -F"=" '{ print $2 }')
export CHART_REPO_URL
CHART_REPO_NAME=$(yq e '.spec.chart.spec.sourceRef.name' "${manifest}")
export CHART_REPO_NAME
CHART_NAME=$(yq e '.spec.chart.spec.chart' "${manifest}")
export CHART_NAME
CHART_VERSION=$(yq e '.spec.chart.spec.version' "${manifest}")
export CHART_VERSION
CHART_NAMESPACE=$(yq e '.spec.targetNamespace' "${manifest}")
export CHART_NAMESPACE

# Debug:
if [ -n "${DEBUG}" ]; then
    echo "${CHART_REPO_URL}"
    echo "${CHART_REPO_NAME}"
    echo "${CHART_NAME}"
    echo "${CHART_VERSION}"
    echo "${CHART_NAMESPACE}"
fi
