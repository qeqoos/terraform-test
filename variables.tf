variable "profile" {
  type    = string
  default = "tf_user"
}

variable "environment" {
  type = string
  default = "test"
}
variable "region-default" {
  type    = string
  default = "eu-central-1"
  nullable = false
}

variable "subnet_cidr_blocks" {
  type = map(any)
  default = {
    "public1"  = "10.0.1.0/24"
    "private1" = "10.0.2.0/24"
    "public2"  = "10.0.10.0/24"
    "private2" = "10.0.11.0/24"
  }
}

variable "instance_ports_to_open" {
  type = list
  default = ["80","22"]
  validation {
    condition = alltrue([
       for port in var.instance_ports_to_open : port > -1 && port < 65535
    ])
    error_message = "Invalid port(s) given. Please, enter value from valid range 0-65535."
  }
}

variable "vpc_name" {
  type = string
  default = "VPC"
}

variable "path_to_pub_key" {
  type = string
  default = "/home/pavel/.ssh/ecs-instance-key.pub"
  sensitive = true
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "path_to_user_data" {
  type = string
  default = "nginx_user_data.sh.tpl"
}

variable "user_data_template_fill" {
  type = object({
    name = string
    object = string
    game = string
    heroes = list(string)
  })
  default = {
    name   = "pavel",
    object = "yomama",
    game   = "dota",
    heroes = ["SPIRIT BREAKER", "NAGA SIREN", "WINTER WYVERN", "JAKIRO", "JUGGERNAUT"]
  }
}
variable "max_instances_scaling" {
  type = number
  default = 2
}
variable "min_instances_scaling" {
  type = number
  default = 2
}
variable "desired_instances_scaling" {
  type = number
  default = 2
}

variable "project_tags" {
  type = map
  default = {
    creator = "Pavel Qeqoos"
    project = "GGG"
  }
}

locals {
  curr_env_tags = {
    environment = "${var.environment}"
    creator = var.project_tags["creator"]
    project = var.project_tags["project"]
  }
}