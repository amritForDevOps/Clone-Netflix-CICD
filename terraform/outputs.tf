output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "netflix_clone_repo_url" {
  value = aws_ecr_repository.netflix_clone_repo.repository_url
}
