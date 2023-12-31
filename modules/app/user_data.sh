#!/bin/bash

sudo yum install python3.11-pip.noarch -y
sudo pip3.11 install botocore boto3
sudo yum install ansible -y
ansible-pull -i localhost, -U https://github.com/Hari-Develop/anisble_poject.git expense.yml -e role_name=${role_name} -e env=${env} | tee -a /opt/userdata.log
