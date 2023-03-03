provider "aws" {
  region = "us-east-1"
  alias  = "east"
}

provider "aws" {
  region = "us-east-2"
  alias  = "east2"
}
