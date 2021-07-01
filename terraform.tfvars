General_variables  = {
  web_keypair      =  "vpc-a"
  app_key          = "10.0.0.0/16"
}
  PrivSubCidr      = "10.0.1.0/24"

  instance         = {
  instance_types   =  ["t2.micro"]
  subnet_az        = ["us-east-1a"]
}
 instance-type    = "t2.micro"
 asg-min-max-def-size = {
   asg-num = [1, 2, 3]
 }
 alb-name        = "app-load-balancer-w-terraform"
