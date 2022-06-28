#!/bin/bash

# Check if token is already exported to environment...

if [ -z "$AWS_ACCESS_KEY_ID" ]
then
    read -p "Enter AWS_ACCESS_KEY_ID:  " access_id
    export AWS_ACCESS_KEY_ID="$access_id"

    read -p "Enter AWS_SECRET_ACCESS_KEY:  " secret_access_key
    export AWS_SECRET_ACCESS_KEY="$secret_access_key"
else
      echo "Access key already exists..."
fi


# Terraform nodes...
cd terraform && terraform init

terraform plan

terraform apply


# Copy instance IP addresses to ansible inventory file...

terraform output -json instance_ip | jq .[0] | tr -d '"' > ../ansible/inventory
terraform output -json instance_ip | jq .[1] | tr -d '"' >> ../ansible/inventory

cd ansible && ansible-playbook main.yml -i inventory --user ubuntu --key-file ~/.ssh/id_rsa

