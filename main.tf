terraform {
  backend "local" {
    path = "/home/pavel/tf/tf_state"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region-default
}
