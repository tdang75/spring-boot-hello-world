resource "aws_ecs_cluster" "springboot_cluster" {
  name = "springboot-cluster"
}
resource "aws_ecs_task_definition" "springboot_task" {
  family                   = "springboot-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "springboot-app"
    image     = "${aws_ecr_repository.app_repo.repository_url}:latest"
    cpu       = 512
    memory    = 1024
    essential = true
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]
  }])
}


resource "aws_ecs_service" "springboot_service" {
  name            = "springboot-service"
  cluster         = aws_ecs_cluster.springboot_cluster.id
  task_definition = aws_ecs_task_definition.springboot_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
