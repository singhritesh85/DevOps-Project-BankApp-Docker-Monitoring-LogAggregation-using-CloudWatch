variable "vpc_cidr"{

}

variable "private_subnet_cidr"{

}

variable "public_subnet_cidr"{

}

data "aws_partition" "amazonwebservices" {
}

data "aws_region" "reg" {
}

data "aws_availability_zones" "azs" {
}

data "aws_caller_identity" "G_Duty" {
}

variable "igw_name" {

}

variable "natgateway_name" {

}

variable "vpc_name" {

}

variable "instance_type" {

}

variable "env" {

}

########################################### variables to launch EC2 ############################################################

variable "provide_ami" {

}

#variable "vpc_security_group_ids" {

#}

variable "kms_key_id" {

}

variable "cidr_blocks" {

}

variable "name" {

}


############################################# Variables to create ALB ############################################################

variable "application_loadbalancer_name" {

}
variable "internal" {

}
variable "load_balancer_type" {

}
#variable "security_groups" {     ## Security groups are not supported for network load balancers

#}
variable "enable_deletion_protection" {

}
variable "s3_bucket_exists" {

}
variable "access_log_bucket" {

}
variable "prefix" {

}
variable "idle_timeout" {

}
variable "enabled" {

}
variable "target_group_name" {

}
variable "instance_port" {    #### Don't apply when target_type is lambda

}
variable "instance_protocol" {          #####Don't use protocol when target type is lambda

}
variable "target_type_alb" {

}
variable "load_balancing_algorithm_type" {

}
variable "healthy_threshold" {

}
variable "unhealthy_threshold" {

}
variable "healthcheck_path" {

}
#variable "ec2_instance_id" {

#}
variable "timeout" {

}
variable "interval" {

}
variable "ssl_policy" {

}
variable "certificate_arn" {

}
variable "type" {

}
