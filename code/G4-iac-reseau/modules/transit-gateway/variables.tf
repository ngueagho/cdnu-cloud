variable "project_name"           { type = string }
variable "environment"            { type = string }
variable "vpc_ids"                { type = map(string) }
variable "private_subnet_ids"     { type = map(list(string)) }
variable "vpc_cidrs"              { type = map(string) }
variable "private_route_table_ids" {
  type    = map(string)
  default = {}
}
