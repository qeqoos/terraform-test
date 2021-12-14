output "Caller" {
  value = data.aws_caller_identity.name
}

output "Current_region" {
  value = data.aws_region.name
}

output "All_AZs" {
  value = data.aws_availability_zones.azs.names

}

output "All_AZs2" {
  value = data.aws_availability_zones.azs.id

}

output "alb_address" {
  value = aws_lb.web_alb.dns_name
}
