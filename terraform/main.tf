module "aws-eks-existing" {
  source = "./aws-eks-existing"
  cluster_name = var.aws_eks_cluster_name
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "apiconnect" {
  source = "./apiconnect"
  kubeconfig = module.aws-eks-existing.kubeconfig
  cloudprovider = "aws"
  entitlement-key = var.ibm_entitlement_key
  apimanager-ca-file = var.apimanager-ca-file
  ingress-subdomain = var.ingress-subdomain
}
