resource "aws_codebuild_project" "terraform_project" {
  name         = "TerraformDeploy"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = file("terraform-buildspec.yml")
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/terraform:latest"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = aws_ecs_cluster.springboot_cluster.name
    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = aws_ecs_service.springboot_service.name
    }
  }
}
