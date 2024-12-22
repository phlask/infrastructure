variable "env_name" {
  type = string
}

variable "default_cache_behavior" {
  type    = any
  default = {}
}

variable "ordered_cache_behavior" {
  type    = any
  default = []
}

variable "common_domain" {
  type = string
}

variable "additional_aliases" {
  type = list(string)
  default = []
}

variable "custom_error_response" {
  type = any
  default = []
}

variable "origin_access_control_id_images" {
  type = string
}