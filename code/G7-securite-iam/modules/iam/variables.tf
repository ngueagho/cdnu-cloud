variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "s3_bucket_arns"     { type = map(string); default = {} }
variable "ecr_repository_arn" { type = string; default = "" }
