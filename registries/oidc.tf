
# OIDC
data "aws_iam_openid_connect_provider" "existing" {
  url = var.github_oidc_url
}

resource "aws_iam_openid_connect_provider" "github" {
  count = length(data.aws_iam_openid_connect_provider.existing.url) == 0 ? 1 : 0

  url = var.github_oidc_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}
