variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use for authentication."
  type        = string
}

variable "aws_ec2_key_name" {
  description = "The name of the key pair to use for the EC2 instance."
  type        = string
}

variable "aws_availability_zone" {
  description = "The AWS availability zone to deploy the EC2 instance in."
  type        = string
}
