variable "project_name"       { type = string; default = "cdnu-cloud" }
variable "environment"        { type = string; default = "prod" }
variable "aws_region"         { type = string; default = "eu-west-1" }
variable "monthly_budget_usd" { type = number; default = 3000 }
variable "alert_emails" {
  type    = list(string)
  default = ["dsi@minesup.cm", "cloud-admin@minesup.cm"]
}
variable "cdnu_list" {
  type    = list(string)
  default = ["yaounde-1","douala-1","bafoussam-1","ngaoundere-1","garoua-1","maroua-1","ebolowa-1","bertoua-1","limbe-1","buea-1"]
}
