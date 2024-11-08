variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "test-nginx"
}

variable "external_port" {
  description = "External port to map to the container"
  type        = number
  default     = 8080
}
