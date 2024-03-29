# apic-remote-gw

Gitops config for deploying API Connect gateway and analytics

## Preparing your own version of this repo

Make a fork of this repository and update the following:

### Ingress subdomain

Make sure to update [env/nonprod/gatewaycluster/custom/ingress-subdomain.yaml](env/nonprod/gatewaycluster/custom/ingress-subdomain.yaml) to have the host name for your ingress subdomain. 

Your cluster needs to have the nginx ingress controller with SSL passthrough enabled. See: https://www.ibm.com/docs/en/api-connect/10.0.5.x_lts?topic=deployment-kubernetes-ingress-controller-prerequisites

### Gitops repository

Make sure to update [argocd/kustomization.yaml](argocd/kustomization.yaml) and [argocd/bootstrap.yaml](argocd/bootstrap.yaml) with the git repo and revision used in your fork of this repository.

## Preparing a fresh Kubernetes environment

Log into the cluster so you can use `kubectl` against it.

### Install OLM

Datapower and API connect are installed through operators so we need OLM to be installed. First of all `operator-sdk` CLI tool is needed. For MacOS it can be installed with `brew install operator-sdk`, otherwise see here: <https://sdk.operatorframework.io/docs/installation/>

Install OLM by running

```bash
operator-sdk olm install
```

For details see here: <https://olm.operatorframework.io/docs/getting-started/>

### ArgoCD

See details in [argocd/argo-setup/README.md](argocd/argo-setup/README.md) for Argo CD installation.

## Add the ArgoCD applications

To install the remote gateway and its dependencies apply the necessary ArgoCD applications through the bootstrap application as follows:

**_NOTE_**: Replace URL with the one of your forked repo.

```bash
kubectl apply -f https://raw.githubusercontent.com/Nordic-MVP-GitOps-Repos/apic-remote-gw/main/argocd/bootstrap.yaml -n argocd
```

## Secrets needed

Replace `<password>` with something hard to guess

`kubectl create secret generic admin-credentials --from-literal=password=<password> -n apic`

Add the API manager CA following these instructions:

1. Extract the CA from the API manager endpoint and rename it to api-manager.crt
2. Add the CA into a secret using the following command

`kubectl create secret generic apimanager-ca --from-file=./api-manager.crt -n apic`

Add the IBM entitlement key following these instructions:

1. Log in to [https://myibm.ibm.com/products-services/containerlibrary](https://myibm.ibm.com/products-services/containerlibrary) with an IBMid and password associated with the entitled software.
2. Select the **View library** option to verify your entitlement(s).
3. Select the **Get entitlement key** to retrieve the key.

```bash
kubectl create secret docker-registry ibm-entitlement-key -n apic \
--docker-username=cp \
--docker-password="<entitlement_key>" \
--docker-server=cp.icr.io
```
## Register the new gateway with API Manager

Extract the remote gateway client certificates:

```
kubectl -n apic get secrets gateway-client-client -o yaml > secret.yaml

grep ca.crt secret.yaml | head -1 | awk '{print $2}' | base64 -d > ca.crt.pem
grep tls.crt secret.yaml | head -1 | awk '{print $2}' | base64 -d > tls.crt.pem
grep tls.key secret.yaml | head -1 | awk '{print $2}' | base64 -d > tls.key.pem
```

In APIM Cloud Manager, Under Resources / TLS, create a new Keystore and Truststore with the above certificates. Create a new TLS Client Profile with the Keystore and Truststore you just created.

In APIM Cloud Manager, under Topology, Register the remote gateway with the TLS Client Profile you just created and the management and API endpoints pointing to the hosts you've setup in [ingress-subdomain.yaml](env/nonprod/gatewaycluster/custom/ingress-subdomain.yaml)

## Enable the new gateway for a catalog

In APIM API Manager, under Manage Catalogs, find the Catalog you'd like to use the remote gateway with. In the Catalog, under Catalog Settings/Gateway Services, add the remote gateway.

## References

This is based on https://community.ibm.com/community/user/integration/blogs/christopher-phillips1/2021/02/08/how-to-configure-your-gateway-in-a-different-cloud

Documentation on API Connect and DataPower operator install: https://www.ibm.com/docs/en/api-connect/10.0.x?topic=do-deploying-operators-in-single-namespace-api-connect-cluster

Installing DataPower Subsystem for API Connect: https://www.ibm.com/docs/en/api-connect/10.0.x?topic=subsystems-installing-datapower-gateway-subsystem
