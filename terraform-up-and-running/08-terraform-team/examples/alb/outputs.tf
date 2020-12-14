output "alb_dns_name" {
  value = module.alb.alb_dns_name
  description = "The domain name of the LB"
}