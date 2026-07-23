resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  ttl     = "3"
  records = [aws_eip.Rakesh[0].public_ip]
  allow_overwrite = true
}

resource "aws_route53_record" "jenkins_agent" {
  count = var.jenkins ? 1 : 0
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "jenkins-agent.${var.domain_name}"
  type    = "A"
  ttl     = "3"
  records = [aws_instance.jenkins_agent[0].private_ip]
  allow_overwrite = true
  
}


resource "aws_route53_record" "sonar" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "sonarqube.${var.domain_name}"
  type    = "A"
  ttl     = 3
  records = [aws_instance.sonarqube[0].public_ip]
    allow_overwrite = true

}

