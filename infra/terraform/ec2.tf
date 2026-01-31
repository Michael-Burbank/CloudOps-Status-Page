

# Retrieve the latest Amazon Linux 2023 AMI with kernel 6.12.
data "aws_ssm_parameter" "al2023_612" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.12-x86_64"
}

# Define the AWS EC2 instance.
resource "aws_instance" "web_server" {
  ami                  = data.aws_ssm_parameter.al2023_612.value
  instance_type        = "t3.small"
  monitoring           = true
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  # Configure the root block device with gp3 volume type, 10GB size, 3000 IOPS, and 125 MB/s throughput.
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    iops        = 3000
    throughput  = 125
  }

  # Add networking, key_name, and security groups as needed.
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.aws_ec2_key_name
  tags = {
    Name        = "CloudOps-Status-Page"
    Environment = var.environment
  }
}

# Create an IAM instance profile to attach the role to the EC2 instance.
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_access.name
}

# Create the virtual private cloud (VPC).
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create the security group for the EC2 instance.
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name        = "web-sg"
    Environment = var.environment
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.owner_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the subnet in the specified availability zone.
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.aws_availability_zone
  tags = {
    Name = "main-subnet"
  }
}

resource "aws_eip" "web_eip" {
  # No arguments needed for VPC EIP
}

# Create an Elastic IP and associate it with the EC2 instance.
resource "aws_eip_association" "web_eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_eip.id
}

output "instance_public_ip" {
  value = aws_eip.web_eip.public_ip
}

output "instance_id" {
  value = aws_instance.web_server.id
}

output "instance_public_dns" {
  value = aws_instance.web_server.public_dns
}

# Configure the Internet Gateway.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a route table and a default route to the Internet Gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # Configures a default route to the Internet Gateway with open access.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the route table with the subnet.
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}

# Create an IAM role for the EC2 instance. 
# This role is needed to ensure the EC2 instance can interact with the S3 bucket.
resource "aws_iam_role" "ec2_s3_access" {
  name               = "ec2-s3-access-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ec2_s3_policy" {
  name   = "ec2-s3-access"
  role   = aws_iam_role.ec2_s3_access.id
  policy = data.aws_iam_policy_document.ec2_s3_policy.json
}

data "aws_iam_policy_document" "ec2_s3_policy" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources = [
      aws_s3_bucket.cloudops_status_page_bucket.arn,
      "${aws_s3_bucket.cloudops_status_page_bucket.arn}/*"
    ]
  }
}
