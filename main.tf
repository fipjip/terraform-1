provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c91f97cadcc8499e"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"

  }
}
