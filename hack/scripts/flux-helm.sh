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

# NO_COLOR="\033[0m"
# DEBUG_COLOR="\e[34m"
# INFO_COLOR="\e[32m"
# ERROR_COLOR="\e[31m"
# WARN_COLOR="\e[35m"

function usage() {
    echo "Usage: $0 <service> <overlay>"
}

function helm_values() {
    chart=$1
    overlay=$2
    # shellcheck disable=SC2001
    overlay_values=$(echo "${chart}" | sed -e "s#base#overlays/${overlay}#g")
    # echo "${overlay_values}"

    tmpfile=$(mktemp)
    if [ ! -f "${overlay_values}" ]; then
        # shellcheck disable=SC2016
        yq ea '. as $item ireduce ({}; . * $item )' "${chart}" | yq e '.spec.values' - > "${tmpfile}"
    else
        # shellcheck disable=SC2016
        yq ea '. as $item ireduce ({}; . * $item )' "${chart}" "${overlay_values}" | yq e '.spec.values' - > "${tmpfile}"
    fi
    echo "${tmpfile}"
}


if [ $# -ne 2 ]; then
    usage
else
    helm_values "$1" "$2"
fi
