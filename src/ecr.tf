resource "aws_ecr_repository" "app_repo" {
  name                 = "springboot-app-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
