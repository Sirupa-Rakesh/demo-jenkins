resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.Rakesh[0].public_ip]
}

resource "aws_route53_record" "sonarqube" {
  count   = var.sonar ? 1 : 0

  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "sonar.${var.domain_name}"
  type    = "A"
  ttl     = 300

  records = [aws_eip.sonarqube[count.index].public_ip]
}