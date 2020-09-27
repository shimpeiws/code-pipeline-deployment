data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "code_build_role" {
  name               = "code-build-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "code_build_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "code_build_policy" {
  role   = aws_iam_role.code_build_role.name
  policy = data.aws_iam_policy_document.code_build_policy.json
}

resource "aws_codebuild_project" "deploy" {
  name          = "${var.code_build_project_name}"
  description   = "code build for plan"
  build_timeout = "60"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:light"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "${var.github_project_url}" //GitHub project URL
    git_clone_depth = 1
    buildspec       = "${var.buildspec_path}" //GitHubにあるbuildspec.ymlの場所
  }
}
