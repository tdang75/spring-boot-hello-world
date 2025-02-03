resource "aws_codestarconnections_connection" "github_connection" {
  name = "github-connection"
  provider_type = "GitHub"
}
