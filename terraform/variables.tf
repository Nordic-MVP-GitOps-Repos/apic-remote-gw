variable "aws_access_key" {
  description = "The AWS access key"
  sensitive = true
}

variable "aws_secret_key" {
  description = "The AWS secret key"
  sensitive = true
}

variable "aws_region" {
  description = "The AWS region"
}

variable "aws_eks_cluster_name" {
  description = "The existing AWS EKS cluster name"
}

variable "ingress-subdomain" {
  description = "The ingress subdomain of the AWS EKS cluster"
}

variable "ibm_entitlement_key" {
  description = "The IBM entitlement key"
  sensitive = true
}

variable "apimanager-ca-file" {
  description = "The file location of the API manager root CA"
}

