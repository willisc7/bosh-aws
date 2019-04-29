#!/bin/bash
set -e

ROOT_DIR=$(pwd)

if [[ ! -d "${ROOT_DIR}/bosh-deployment" ]]; then
    git clone https://github.com/cloudfoundry/bosh-deployment
fi

if [[ -f "~/.ssh/jumpbox_key" ]]; then
    ssh-keygen -N "" -t rsa -b 4096 -f ~/.ssh/jumpbox_key
    chmod 600 ~/.ssh/jumpbox_key ~/.ssh/jumpbox_key.pub
fi

set_vars() {
  cd ${ROOT_DIR}/terraform
  JSON=$(terraform output -json)
  cd ${ROOT_DIR}

  JUMPBOX_EIP=$(echo $JSON | jq -r '.jumpbox_eip.value')
  WORKSPACE_NAME=$(echo $JSON | jq -r '.tag_name.value')
  BOSH_VPC_CIDR=$(echo $JSON | jq -r '.bosh_vpc_cidr.value')
  BOSH_VPC_GW=$(echo $JSON | jq -r '.bosh_vpc_gw.value')
  BOSH_INTERNAL_IP=$(echo $JSON | jq -r '.bosh_internal_ip.value')
  AWS_REGION=$(echo $JSON | jq -r '.aws_region.value')
  BOSH_AVAILABILITY_ZONE=$(echo $JSON | jq -r '.public_subnet_az.value')
  PUBLIC_SUBNET_ID=$(echo $JSON | jq -r '.public_subnet_id.value')
}

deploy_bosh(){
    ssh -tt -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${JUMPBOX_EIP} -i ~/.ssh/jumpbox_key bash << EOF
        set -e

        aws configure

        bosh create-env ${ROOT_DIR}/bosh-deployment/bosh.yml \
        --state=state.json \
        --vars-store=creds.yml \
        -o ${ROOT_DIR}/bosh-deployment/aws/cpi.yml \
        -v director_name=bosh-1-${WORKSPACE_NAME} \
        -v internal_cidr=${BOSH_VPC_CIDR} \
        -v internal_gw=${BOSH_VPC_GW} \
        -v internal_ip=${BOSH_INTERNAL_IP} \
        -v region=${AWS_REGION} \
        -v az=${BOSH_AVAILABILITY_ZONE} \
        -v default_key_name=bosh \
        -v default_security_groups=[bosh] \
        --var-file private_key=~/Downloads/bosh.pem \
        -v subnet_id=${PUBLIC_SUBNET_ID}
EOF
}

cd ${ROOT_DIR}/terraform
terraform init
terraform apply
cd ${ROOT_DIR}
set_vars
# WIP: figure out how to read AWS access key into SSH session with jumpbox
#deploy_bosh