resource "aws_iam_role" "gh_actions" {
  name = "gh-actions"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17"
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.gh_actions_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:integraldx/*:*"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "gh_actions_policy" {
  name = "gh-actions-policy"
  description = "GitHub Actions policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*Object*"
      ]
    }
  ]
}
EOF
}

data "tls_certificate" "gh_actions_certificate" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "gh_actions_provider" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.gh_actions_certificate.certificates[*].sha1_fingerprint
}

resource "aws_iam_role_policy_attachment" "gh_actions_attachment" {
  role = aws_iam_role.gh_actions.name
  policy_arn = aws_iam_policy.gh_actions_policy.arn
}
