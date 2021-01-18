variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "ecs_task_cpu" {
  default = 256
}
variable "ecs_task_memory" {
  default = 512
}

variable "slackbot-secret" {
  default = {
    SLACK_APP_TOKEN = "DONTBESILLYANDSTOREYOURSECRETSINPLAINTEXT"
    SLACK_BOT_TOKEN = "DONTBESILLYANDSTOREYOURSECRETSINPLAINTEXT"
  }

  type = map(string)
}
