variable "ami_key_pair_name" { #Todo: uncomment the default value and add your pem key pair name. Hint: don't write '.pem' exction just the key name
        default = "verginia" 
}

variable "region" {
        description = "The region zone on AWS"
        default = "us-east-1" #The zone I selected is us-east-1, if you change it make sure to check if ami_id below is correct.
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-053b0d53c279acc90" #Ubuntu 20.04
}

variable "instance_type" {
        default = "t2.micro" #the best type to start k8s with it,
}