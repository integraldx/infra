#! /bin/bash
sudo yum update -y
sudo yum install -y docker
sudo yum install -y docker-compose
sudo yum install -y ruby
sudo yum install -y wget
sudo yum install -y ec2-instance-connect

sudo service docker start
sudo usermod -a -G docker ec2-user

cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
