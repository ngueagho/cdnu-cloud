output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_arn" {
  value = aws_ec2_transit_gateway.main.arn
}

output "attachment_ids" {
  value = { for k, v in aws_ec2_transit_gateway_vpc_attachment.cdnu : k => v.id }
}
