#! /bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo docker pull nginx:latest
sudo docker run --name nginx -p 80:80 -d nginx
