
variable "General_variables" {
  description = "Select a keypair for WebServers"
  type      = map(string)
}

variable "PrivSubCidr" {
  description = "privide a cidr for Pub subnet"
  #default = [for i in range(1, 225, 2) : cidrsubnet(local.cidrblocks[2], 8, i)]
}

variable "instance" {
  description = "privide a cidr for Privte subnet"
  type = map(list(string))
}

variable "ssh-http" {
  description = "privide a cidr for Privte subnet"
  type = map(list(string))
  default = {
    ssh  =  ["0.0.0.0/0", "10.0.0.0/24"]
  }
}
 variable "user_data_path" {
   default = "userdata.tpl"
 }

   variable "public_ip" {
     type  = bool
     default = false
   }

    variable "tolal_count" {
      type = string
      default = 2
    }
   variable "aws_region" {
   default = "us-east-1"
 }
  variable "private_az" {
    default = "us-east-1b"
  }
   variable "enviroment" {
     default = "prod"
   }

    variable "data_values" {
      default = ["RHEL_HA-8.4.0_HVM-20210504-x86_64-2-Hourly2-GP2"]
    }

    variable "launch-config-name" {
   description = "The name of the launch configuration"
   type        = string
   default     = "launch-configuration-created-with-terraform"
   }

   variable "instance-type" {
  description = "The instance type to be used"
  #default     = "t2.micro"
 }

 variable "asg-min-max-def-size" {
 description = "The minimum size of the Auto Scaling Group"
 type        = map(list(string))
 #default     = 2
}
variable "health_check_grace_period" {
description = "Time (in seconds) after instance comes into service before checking health."
type        = string
default     = 3
}

variable "alb-name" {
 description = "The application Load Balancer name"
 }
 variable "target-group-name" {
 description = "The name of the placement group"
 type        = string
 default     = "lb-tg"
}

variable "health-check-path" {
 description = "The apps public sub domain name"
 type        = string
 default     = "/"
}

variable "health-check-port" {
 description = "The apps public sub domain name"
 type        = string
 default     = "80"
}

variable "health_check_interval" {
 description = "The interval between health checks"
 type        = string
 default     = 5
}

variable "health_check_threshold" {
 description = "The number of consecutive health checks to be considered (un)healthy."
 type        = string
 default     = 3
}

variable "health_check_grace_per" {
 description = "Time (in seconds) after instance comes into service before checking health."
 type        =  string
 default     = 3
}
variable "use_https_only" {
 description = "If true, forces all http traffic to https"
 type        = string
 default     = "false"
}

variable "ssl_certificate_arn" {
description = "The ARN of the SSL certificate for the load-balancer"
type        = string
default     = ""
}
