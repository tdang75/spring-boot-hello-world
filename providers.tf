provider "aws" {
  region = "us-east-1"
}

variable "github_repo" {
  default = "spring-boot-hello-world"
}

variable "github_owner" {
  default = "tdang75"
}

variable "github_branch" {
  default = "main"
}

variable "github_token" {}
