variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "rds_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "cloud4health"
}

variable "db_username" {
  type    = string
  default = "c4hadmin"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro" # Free Tier
}

variable "allocated_storage" {
  type    = number
  default = 20 # GB - Free Tier
}

variable "multi_az" {
  type    = bool
  default = true # Alta disponibilidade
}

variable "backup_retention_period" {
  type    = number
  default = 7 # dias
}

variable "tags" {
  type = map(string)
}

variable "monitoring_role_arn" {
  description = "ARN do IAM Role para Enhanced Monitoring"
  type        = string
}