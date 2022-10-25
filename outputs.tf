# Output the DNS name of load balancer
output "alb_url" {
  value = module.knab_networking.alb_url
}