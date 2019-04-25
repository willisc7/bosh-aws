#!/bin/bash

ROOT_DIR=$(pwd)

if [ ! -d "${ROOT_DIR}/bosh-deployment" ]; then
    git clone https://github.com/cloudfoundry/bosh-deployment
fi

cd ${ROOT_DIR}/terraform
terraform init
terraform apply