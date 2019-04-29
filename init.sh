#!/bin/bash
set -e

ROOT_DIR=$(pwd)

# TODO: output the BOSH EIP once its assigned to the instance
# set_vars() {
#   cd ${ROOT_DIR}/terraform
#   JSON=$(terraform output -json)
#   cd ${ROOT_DIR}

#   BOSH_EIP=$(echo $JSON | jq -r '.vpc_id.value')
# }

if [[ ! -d "${ROOT_DIR}/bosh-deployment" ]]; then
    git clone https://github.com/cloudfoundry/bosh-deployment
fi

if [[ -f "~/.ssh/jumpbox_key" ]]; then
    ssh-keygen -N "" -t rsa -b 4096 -f ~/.ssh/jumpbox_key
    chmod 600 ~/.ssh/jumpbox_key ~/.ssh/jumpbox_key.pub
fi 

cd ${ROOT_DIR}/terraform
terraform init
terraform apply

echo \
"####
TODO:
  - Put jumpbox_eip in manifest.yml
####"