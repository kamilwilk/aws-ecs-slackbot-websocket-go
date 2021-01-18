resource "aws_ecr_repository" "slackbot" {
  name = "slackbot"
}

resource "aws_ecr_repository_policy" "slackbot" {
  repository = aws_ecr_repository.slackbot.name

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.ecs_task_execution_role.arn}"
        ]
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
POLICY
}
