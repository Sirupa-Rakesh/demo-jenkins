output "public_ip" {
  value = aws_eip.Rakesh.public_ip
}

output "jenkins_url" {
  value = "http://${var.subdomain}.${var.domain_name}:8080"
}