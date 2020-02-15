provider "aws" {
  region = "ap-northeast-1" # Tokyo
  version = "~> 2.49"
  profile = "94xychen"
}

module "aws" {
  source = "./aws"
}
