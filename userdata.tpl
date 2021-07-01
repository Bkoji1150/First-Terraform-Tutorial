#!/bin/bash
# Use This For your database (Script from to to bottom)
# Install http (linux Redhat)
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>    Ec2  from Oregon $(hostname -f)</h1>" > /var/www/html/index.html
