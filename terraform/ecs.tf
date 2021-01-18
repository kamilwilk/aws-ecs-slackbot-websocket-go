resource "aws_ecs_cluster" "slackbot" {
  name = "slackbot-cluster"
}

resource "aws_ecs_task_definition" "slackbot" {
  family = "slackbot-task"
  //task_role_arn            = "" Don't need one in this basic example, but if you want the bot to do some stuff like call lambdas or write to s3, then you'll want to setup a task role
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = templatefile("${path.module}/templates/slackbot_container_definition.json.tpl", {
    aws_region           = var.aws_region
    cloudwatch_logsgroup = aws_cloudwatch_log_group.slackbot.name
    container_image      = "${aws_ecr_repository.slackbot.repository_url}:latest"
    container_cpu        = var.ecs_task_cpu
    container_memory     = var.ecs_task_memory
    slackbot_secret      = aws_secretsmanager_secret.slackbot.arn
  })
}

resource "aws_ecs_service" "slackbot" {
  name            = "slackbot-service"
  cluster         = aws_ecs_cluster.slackbot.id
  task_definition = aws_ecs_task_definition.slackbot.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.slackbot.id]

    // use a public subnet with IGW for cost savings
    subnets          = [aws_subnet.slackbot.id]
    assign_public_ip = true

    // if you want to keep your slackbot service in a private subnet uncomment below and remove the above
    // be aware of NAT gateway pricing though, not my fault if you run your AWS bill up!
    //subnets          = [aws_subnet.slackbotprivate.id]
    //assign_public_ip = false

  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}
