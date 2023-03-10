module "ibm-vpc" {
  source = "./ibm-vpc"
  name = "apic-remote-gw"
  ibmcloud_api_key = var.ibmcloud_api_key
}

module "apiconnect" {
  source = "./apiconnect"
  kubeconfig = module.ibm-vpc.kubeconfig
  cloudprovider = "ibm-vpc"
  entitlement-key = var.ibm_entitlement_key
  apimanager-ca-file = var.apimanager-ca-file
  ingress-subdomain = module.ibm-vpc.ingress-subdomain
}
