#!/usr/bin/env bash



aws s3 cp s3://s3-awsdemowebapp-terraform/initial_config/initial_playbook.yml /tmp/playbook.yml
aws s3 cp s3://s3-awsdemowebapp-terraform/initial_config/requirements.yml /tmp/requirements.yml
aws s3 cp s3://s3-awsdemowebapp-terraform/initial_config/execute_ansible.sh /tmp/execute_ansible.sh

chmod +x /tmp/execute_ansible.sh

cd /tmp
ansible-galaxy install -r requirements.yml
ansible-playbook -i localhost /tmp/playbook.yml