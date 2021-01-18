resource "aws_secretsmanager_secret" "slackbot" {
  name = "/ecs/slackbot-token"
}

resource "aws_secretsmanager_secret_version" "slackbot" {
  secret_id     = aws_secretsmanager_secret.slackbot.id
  secret_string = jsonencode(var.slackbot-secret)
}
