[
  {
    "name": "slackbot",
    "image": "${container_image}",
    "cpu": ${container_cpu},
    "memory": ${container_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${cloudwatch_logsgroup}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [],
    "environment": [],
    "secrets": [
        { "name": "SLACK_APP_TOKEN", "valueFrom": "${slackbot_secret}:SLACK_APP_TOKEN::" },
        { "name": "SLACK_BOT_TOKEN", "valueFrom": "${slackbot_secret}:SLACK_BOT_TOKEN::" }
    ]
  }
]
