variable "region" {
  default = "us-east-1"
}

variable "accepter_vpc_id" {
  description = "VPC id that you want to peer with it"
  type        = string
}

variable "accepter_route_table_id" {
  description = "Route table id of the accepter that you want to peer with it"
  type        = string
}

variable "onpremdnsa_priv_ip" {
  description = "Private IP Address of micros4l-onpremdnsa"
  type        = string
}

variable "onpremdnsb_priv_ip" {
  description = "Private IP Address of micros4l-onpremdnsb"
  type        = string
}
