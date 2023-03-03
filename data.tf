#Data file - for getting data on resources

data "aws_vpc" "vpc_test" {
  filter {
    name   = "tag:Name"
    values = ["VPC-Yannick"]
  }
}
