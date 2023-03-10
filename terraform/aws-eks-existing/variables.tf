variable "region" {
  description = "The AWS region"
}

variable "access_key" {
  description = "The AWS access key"
  sensitive = true
}

variable "secret_key" {
  description = "The AWS secret key"
  sensitive = true
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
}
