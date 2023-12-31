provider "aws" {
  region     = var.region
  
}

resource "aws_security_group" "DisnyHotStar" {
  name = "DisnyHotStar"
  
  ingress = [
    for port in [22, 80, 443, 3000, 8080, 9000, 9090] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DisnyHotStar"
  }
}




resource "aws_instance" "ec2_instance_jenkins_sonar_trivy" {
    ami = var.ami_id
    instance_type = "t2.large"
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    vpc_security_group_ids = [ aws_security_group.DisnyHotStar.id ]
    root_block_device {
        volume_size = 30
    delete_on_termination = true
    }
    tags = {
        Name = "jenkins_sonar_trivy"
    }
    user_data = templatefile("scripts/jenkins_sonar_trivy.sh",{})
    
}

resource "aws_instance" "ec2_instance_prometheus_grafana" {
    ami = var.ami_id
        instance_type = var.instance_type
    key_name = var.ami_key_pair_name
    associate_public_ip_address = true
    vpc_security_group_ids = [ aws_security_group.DisnyHotStar.id ]
    root_block_device {
        volume_size = "8"
    delete_on_termination = true
    }
    tags = {
        Name = "prometheus_grafana"
    }
    user_data = templatefile("scripts/prometheus_grafana.sh",{})
    
}