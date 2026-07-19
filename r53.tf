resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name = "${var.subdomain}.${var.domain_name}"
  type = "A"
  ttl = 300
  records = [aws_eip.Rakesh.public_ip]
}