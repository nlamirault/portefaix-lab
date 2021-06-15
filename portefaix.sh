#!/usr/bin/env bash

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

OK_COLOR="\e[32m"
KO_COLOR="\e[31m"
NO_COLOR="\e[39m"

echo -e "${OK_COLOR}[ Portefaix ]${NO_COLOR}"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <cloud provider>"
else
    echo -e "${OK_COLOR}Setup credentials ${NO_COLOR}"
    CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
    PORTEFAIX_CONFIG_HOME=${CONFIG_HOME}/portefaix

    export CREDENTIALS=${PORTEFAIX_CONFIG_HOME}/portefaix.sh

    if [ ! -f "${CREDENTIALS}" ]; then
        echo -e "${KO_COLOR}File not found: ${NO_COLOR}${CREDENTIALS}"
    else
        # shellcheck disable=SC1090
        . "${CREDENTIALS}" "$1"
        echo -e "${OK_COLOR}Done${NO_COLOR}"
    fi
fi
