#!/bin/bash
set -e

INVENTORY=${1:-inventory.ini}
PLAYBOOK=${2:-playbooks/site.yml}

echo "Deploying with inventory: ${INVENTORY}"
echo "Using playbook: ${PLAYBOOK}"

# Check the playbook for syntax errors.
echo "Running syntax check..."
ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --syntax-check

# Launch a dry run to see what changes would be made and ensure there are no unexpected issues.
echo "Running dry run..."
ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --check

# Confirm deployment with the user before proceeding.
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Deploying..."
    ansible-playbook -i ${INVENTORY} ${PLAYBOOK}
    
    echo "Running health checks..."
    bash services/michael-burbank/backend/scripts/health-check.sh ${INVENTORY}
    
    echo "Deployment complete!"
else
    echo "Deployment cancelled"
    exit 1
fi