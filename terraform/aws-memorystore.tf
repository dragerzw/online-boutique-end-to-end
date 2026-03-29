# AWS ElastiCache (Redis) for Online Boutique

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "redis_cart" {
  cluster_id           = "redis-cart"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  port                 = 6379
  security_group_ids   = [module.eks.node_security_group_id]
  apply_immediately    = true

  # Only create if memorystore is enabled
  count = var.memorystore ? 1 : 0
}

output "redis_endpoint" {
  description = "Redis endpoint for cart service"
  value       = var.memorystore ? aws_elasticache_cluster.redis_cart[0].cache_nodes[0].address : ""
}
