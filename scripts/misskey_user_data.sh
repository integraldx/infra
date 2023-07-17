#! /bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker
sudo yum install -y ruby
sudo yum install -y wget
sudo yum install -y ec2-instance-connect

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo service docker start
sudo usermod -a -G docker ec2-user

sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
