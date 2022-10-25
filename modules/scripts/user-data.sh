#!/bin/bash
sleep 60
yum update -y
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on
docker pull registry.hub.docker.com/library/nginx
docker run --publish 80:80 registry.hub.docker.com/library/nginx