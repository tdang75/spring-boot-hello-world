resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "my-codepipeline-artifacts-bucket2025"  # Change to a globally unique name
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts_versioning" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_policy" "pipeline_artifacts_policy" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = ["codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
      }
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        "${aws_s3_bucket.pipeline_artifacts.arn}",
        "${aws_s3_bucket.pipeline_artifacts.arn}/*"
      ]
    }]
  })
}
