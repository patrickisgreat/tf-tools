provider "aws" {
  region = var.aws_region

  # Applied to every taggable resource created by this root config.
  default_tags {
    tags = merge(
      {
        Environment = "dev"
        ManagedBy   = "terraform"
        Repo        = "tf-tools"
      },
      var.default_tags,
    )
  }
}
