# Transit Gateway central — interconnecte les 10 VPCs des CDNUs
resource "aws_ec2_transit_gateway" "main" {
  description                     = "TGW central pour les 10 CDNUs MINESUP"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw"
  }
}

# Attachment d'un VPC au Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "cdnu" {
  for_each = var.vpc_ids

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value
  # Attacher au moins un subnet privé par VPC
  subnet_ids = [var.private_subnet_ids[each.key][0]]

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw-attach-${each.key}"
    CDNU = each.key
  }
}

# Route dans chaque VPC vers les autres CDNUs via le TGW
resource "aws_route" "to_other_cdnus" {
  for_each = var.vpc_cidrs

  route_table_id         = var.private_route_table_ids[each.key]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.cdnu]
}
