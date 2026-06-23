
variable "vpc_cidr" {
    description = "CIDR for vpc"
    type = string
    default = "10.0.0.0/16"  
}

variable "cluster_name" {
  description = "name of cluster"
  default = "production-grade"
}

variable "private_subnets" {
  description = "value of private subnet cidr"
  type = list(string)
  default = ["10.0.101.0/24","10.0.2.0/24","10.0.103.0/24" ]
}

variable "public_subnets" {
description = "value of public subnets cidr"
type = list(string)
default = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
}

variable "kubernates_version" {
  description = "kubernates version to be used in cluster"
  type = string
  default = "1.31"
}


variable "aws_region" {
  description = "aws resources created in"
  type = string
  default = "eu-north-1"
}

variable "environment" {
  description = "environment name"
  type = string
  default = "production"
}

variable "enable_db_secret" {
  description = "enable database secret"
  type = bool
  default = true
}

variable "enable_api_secret" {
  description = "enable API secret"
  type = bool
  default = true
}

variable "enable_app_config_secret" {
  description = "enable app config secret"
  type = bool
  default = true
}