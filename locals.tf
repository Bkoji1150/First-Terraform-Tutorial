### -- root/locals ----

locals {
  common_tags = {
    Name = "jjtechAPP"
    App_Name = "ovid"
    Cost_center = "xyz222"
    Business_unit = "GBS"
    Business_unit = "GBS"
    App_role = "web server"
    App_role = "web server"
    Environment = "dev"
    Security_Classification = "NA"
  }
}

locals {
  cidrblocks = ["0.0.0.0/0", "${aws_eip.BrontechEP.public_ip}/32", "10.0.0.0/16"]
}


 locals {
   security_groups = {
   web_sg = {
     name = "web-sg"
     description = "security group for inbound rules"

    ingress = {
    http_proxy = {
      from_port        = 8000
      to_port          = 8000
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    dns_port = {
      from_port        = 53
      to_port          = 53
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    rdp_port = {
      from_port        = 3389
      to_port          = 3389
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    telnet_port = {
      from_port        = 23
      to_port          = 23
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    NTP_port = {
      from_port        = 123
      to_port          = 123
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    NFS_port = {
      from_port        = 2049
      to_port          = 2049
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    Nessus_port  = {
      from_port        = 1241
      to_port          = 1241
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[1]
    }
    Shh    = {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[0]
    }
   }
 }

 rds_sg = {
   name        = "rds_sg"
   description = "rds access"
   ingress = {
     mysql = {
       from_port        = 3306
       to_port         = 3306
       protocol    = "tcp"
       cidr_blocks = local.cidrblocks[2]
     }
    ssh_app = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = local.cidrblocks[2]
    }
   }
   }

  backend_sg   = {
    name        = "backend_sg"
    description = "backend access to resources"
    ingress = {
      mysql = {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = local.cidrblocks[2]
      }
     ssh_app = {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = local.cidrblocks[2]
     }
   }
}
alb_sg = {
  name        = "alb_sg"
  description = "allow alb sg"
  ingress = {
    http = {
      from_port        = 80
      to_port         = 80
      protocol    = "tcp"
      cidr_blocks = local.cidrblocks[0]
    }
    https = {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = local.cidrblocks[0]
    }
}
 }
}
}
 # pg-dock, kibana, liquibase
