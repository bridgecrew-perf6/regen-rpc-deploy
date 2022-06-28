output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.instance[*].public_ip
}

output "lb_dns" {
  description = "The DNS_name for load balancer"
  value       = aws_lb.app.dns_name
}