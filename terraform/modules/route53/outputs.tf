# terraform/modules/route53/outputs.tf
output "fqdn" {
  description = "Fully qualified domain name"
  value       = aws_route53_record.app.fqdn
}