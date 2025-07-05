# terraform/modules/route53/main.tf
# Route 53 A Record
resource "aws_route53_record" "app" {
  zone_id = var.route53_zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id               = var.alb_zone_id
    evaluate_target_health = true
  }

  depends_on = [var.alb_dns_name]
}