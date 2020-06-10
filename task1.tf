provider "aws" {
  region = "ap-south-1"
  profile = "shubham"
}

#creating security group
resource "aws_security_group" "morning-ssh-http" {
  name        = "morning-ssh-http"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#creating aws instance
resource "aws_instance" "good-morning" {
  ami               = "ami-09743796b859ebfc9"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  security_groups   = ["${aws_security_group.morning-ssh-http.name}"]
  key_name = "myoskey"
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "<h1>Sample Webserver Network Nuts" | sudo tee  /var/www/html/index.html
  EOF


  tags = {
        Name = "webserver"
  }

}

#creating and attaching ebs volume

resource "aws_ebs_volume" "data-vol" {
 availability_zone = "ap-south-1a"
 size = 1
 tags = {
        Name = "data-volume"
 }

}
#
resource "aws_volume_attachment" "good-morning-vol" {
 device_name = "/dev/sdc"
 volume_id = "${aws_ebs_volume.data-vol.id}"
 instance_id = "${aws_instance.good-morning.id}"
}
resource "aws_s3_bucket" "task1" {
 bucket = "mybucket-7654098257"
 acl = "public-read"
 versioning {
   enabled = true
 }

 tags = {
   Name = "task1"
 }

}





