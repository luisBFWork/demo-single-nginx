resource "aws_launch_configuration" "ec2_launch_config" {
  image_id             = "ami-0aa7d40eeae50c9a9"
  iam_instance_profile = aws_iam_instance_profile.ec2_agent.name
  security_groups      = [aws_security_group.ec2-instance-sg.id]
  instance_type        = "t2.micro"
  name                 = "ec2_autoscale"
  key_name             = "ec2_key"
   user_data = <<USER_DATA
  #!/bin.bash
    sudo yum update
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    sudo amazon-linux-extras list | grep nginx
    sudo amazon-linux-extras enable nginx1
    sudo yum clean metadata
    sudo yum -y install nginx
    nginx -v #to ensure that nginx is installed
    sudo systemctl start nginx.service
    sudo mkdir /etc/nginx/ssl
    sudo chown -R root:root /etc/nginx/ssl
    sudo chmod -R 600 /etc/nginx/ssl
    sudo  sh etc/ssl/certs/make-dummy-cert nginx.pem
    sudo cp nginx.pem /etc/nginx/ssl
    echo ${filebase64("nginx.conf")} | base64 -d -> nginx.conf
    sudo cp nginx.conf /etc/nginx
    sudo systemctl restart nginx.service
    USER_DATA

}

resource "aws_autoscaling_group" "ec2_asg" {
  name                      = "ec2_asg"
  vpc_zone_identifier       = slice(module.vpc.public_subnets, 1, 2)
  launch_configuration      = aws_launch_configuration.ec2_launch_config.name
  target_group_arns        = [aws_lb_target_group.demo.arn]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_autoscaling_policy" "scale_policy_up" {
    name = "scale_policy_up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
    alarm_name = "cpu_alarm_up"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "60"

    dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
    }
    alarm_description = "This metric monitor EC2 instance utilization"
    alarm_actions = [aws_autoscaling_policy.scale_policy_up.arn]
}

resource "aws_autoscaling_policy" "scale_policy_down" {
    name = "scale_policy_down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
    alarm_name = "cpu_alarm_down"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "40"

    dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
    }
    alarm_description = "This metric monitor EC2 instance utilization"
    alarm_actions = [aws_autoscaling_policy.scale_policy_down.arn]
}

