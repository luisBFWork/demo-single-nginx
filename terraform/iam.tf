data "aws_iam_policy_document" "ec2_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_agent" {
  name               = "ec2-agent"
  assume_role_policy = data.aws_iam_policy_document.ec2_agent.json
}


resource "aws_iam_role_policy_attachment" "ec2_agent" {
  role       = aws_iam_role.ec2_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_instance_profile" "ec2_agent" {
  name = "ec2-agent"
  role = aws_iam_role.ec2_agent.name
}

