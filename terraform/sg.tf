# LB security group
resource "aws_security_group" "ec2-lb-sg" {
  name        = "${var.project_name}-ec2-lb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "EC2 ${var.project_name}"

}
#
resource aws_security_group_rule "lb_ingress_https" {
  from_port         = 443
  protocol          = "TCP"
  security_group_id = aws_security_group.ec2-lb-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 443
  type              = "ingress"
}
resource aws_security_group_rule "lb_ingress_ssh" {
  from_port         = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.ec2-lb-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 22
  type              = "ingress"
}


resource aws_security_group_rule "lb_ingress_http" {
  from_port         =  80
  protocol          = "TCP"
  security_group_id = aws_security_group.ec2-lb-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 80
  type              = "ingress"
}

resource aws_security_group_rule "lb_egress_http" {

  from_port         = 433
  protocol          = "TCP"
  security_group_id = aws_security_group.ec2-lb-sg.id
  source_security_group_id = aws_security_group.ec2-instance-sg.id
  to_port           = 443
  type              = "egress"
}

# instance security group
resource "aws_security_group" "ec2-instance-sg" {
  name        = "${var.project_name}-ec2-instance-sg"
  vpc_id      = module.vpc.vpc_id
  description = "ECS ${var.project_name}"

}
  resource aws_security_group_rule "instance_ingress_https" {

    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.ec2-instance-sg.id
    source_security_group_id = aws_security_group.ec2-lb-sg.id
    to_port           = 443
    type              = "ingress"
  }
# resource aws_security_group_rule "instance_ingress" {
#
#   from_port         = 3000
#   protocol          = "TCP"
#   security_group_id = aws_security_group.ec2-instance-sg.id
# #   cidr_blocks = ["0.0.0.0/0"]
#    source_security_group_id = aws_security_group.ec2-lb-sg.id
#   to_port           = 3000
#   type              = "ingress"
# }

resource aws_security_group_rule "instance_ingress_ssh" {
  from_port         = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.ec2-instance-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 22
  type              = "ingress"
}

resource aws_security_group_rule "instance_egress" {

  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2-instance-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

# rds security group
resource "aws_security_group" "rds-sg" {
  name        = "${var.project_name}-rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "RDS ${var.project_name}"

}

resource aws_security_group_rule "rds_ingress" {

  from_port         = 3006
  protocol          = "tcp"
  security_group_id = aws_security_group.rds-sg.id
  source_security_group_id = aws_security_group.ec2-lb-sg.id
  to_port           = 3006
  type              = "ingress"
}

resource aws_security_group_rule "rds_egress" {

  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}