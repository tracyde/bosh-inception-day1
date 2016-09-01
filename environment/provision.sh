#!/bin/bash

# Variables passed in from terraform, see aws-vpc.tf, the "remote-exec" provisioner
AWS_KEY_ID=${1}
AWS_ACCESS_KEY=${2}
REGION=${3}
VPC=${4}
BOSH_SUBNET=${5}
IPMASK=${6}
BASTION_AZ=${7}
BASTION_ID=${8}
AWS_KEY_NAME=${9}
ELB_DNS_NAME=${10}

# Prepare the jumpbox to be able to install ruby and git-based bosh and cf repos
cd $HOME

sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get update
sudo apt-get autoremove -y
sudo apt-get install -y git unzip tmux git-core curl libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libcurl4-openssl-dev vim-nox zlib1g-dev build-essential libreadline-dev libffi-dev python-software-properties libxslt1-dev whois

# Install Ruby using rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm

# Install bosh tools
sudo wget https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.96-linux-amd64 -O /usr/local/bin/bosh-init
sudo chmod +x /usr/local/bin/bosh-init
gem install bosh_cli --no-ri --no-rdoc
gem install bosh_aws_cpi --no-ri --no-rdoc
sudo wget https://github.com/geofffranks/spruce/releases/download/v1.7.0/spruce-linux-amd64 -O /usr/local/bin/spruce
sudo chmod +x /usr/local/bin/spruce

# Generate the key that will be used to ssh between the inception server and the
# microbosh machine
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Create our workspace directory
mkdir -p /home/ubuntu/workspace
sudo chown -R ubuntu:ubuntu /home/ubuntu/workspace

cd /home/ubuntu/workspace
git clone https://github.com/tracyde/bosh-inception-day1.git

# Inject our terraform settings into the newly created bastion host
cat <<EOF > settings.yml
---
config:
  aws:
    vpc: ${VPC}
    region: ${REGION}
    key_name: ${AWS_KEY_NAME}
    elb_dns: ${ELB_DNS_NAME}
  bosh:
    subnet: ${BOSH_SUBNET}
    cidr: ${IPMASK}
  bastion:
    az: ${BASTION_AZ}
    id: ${BASTION_ID}
EOF
