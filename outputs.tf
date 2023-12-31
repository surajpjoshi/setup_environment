output "instance_jenkins_sonar_trivy_public_ip" {
  description = "Public address IP of ec2_instance_jenkins_sonar_trivy"
  value       = aws_instance.ec2_instance_jenkins_sonar_trivy.public_ip
}

output "instance_prometheus_grafana_public_ip" {
  description = "Public address IP of ec2_instance_prometheus_grafana"
  value       = aws_instance.ec2_instance_prometheus_grafana.public_ip
}

