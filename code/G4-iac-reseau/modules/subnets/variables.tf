variable "cdnu_name"          { type = string }
variable "vpc_id"             { type = string }
variable "public_cidrs"       { type = list(string) }
variable "private_cidrs"      { type = list(string) }
variable "database_cidrs"     { type = list(string) }
variable "availability_zones" { type = list(string) }
variable "project_name"       { type = string }
variable "environment"        { type = string }
