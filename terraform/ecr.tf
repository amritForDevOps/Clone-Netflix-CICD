resource "aws_ecr_repository" "netflix_clone_repo" {
  name                 = "netflix-clone"
  image_tag_mutability = "MUTABLE"
  tags = {
    Project = "${var.cluster_name}"
  }
}