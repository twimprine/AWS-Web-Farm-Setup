#!/usr/bin/env bash

cd /tmp
ansible-galaxy install -r requirements.yml
ansible-playbook -i localhost /tmp/playbook.yml