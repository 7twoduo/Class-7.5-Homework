variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
  default     = "gcp-mastery-495919"
}

variable "region" {
  description = "The region in which to create resources."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "freefree"
}


variable "instance_name" {
  description = "The name of the Compute Engine instance."
  type        = string
  default     = "my-instance"
}