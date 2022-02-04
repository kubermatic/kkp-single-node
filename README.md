# Get started with KKP - “KKP on single node K1”

KKP Master setup on a single master/worker k8s node using Kubeone. Leveraging the kubeone addons capability for this implementation.

## Configure the Enviornment

Here for the demo purpose, we are using AWS Cloud as the underlying infrastructure
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxx
```

## Create Infrasture using Terraform
```bash
eval `ssh-agent`
ssh-add /path/to/.ssh/id_rsa
make k1-tf-apply PROVIDER=aws
```
> Update the terraform.tfvars with required values. 

> **Important**: Add `untaint` flag with value as `true` in the `output.tf` file as shown below
```bash
output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      untaint              = true
```

## Prepare the addon configuration
> Replace the TODO place holder in addons/kkp yaml definitions. 
```bash
export KKP_DNS=xxx.xxx.xxx.xxx
export KKP_USERNAME=xxxx@xxx.xxx
export RANDOM_SECRET=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
export ISSUERCOOKIEKEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
export SERVICEACCOUNTKEY=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
mkdir -p ./aws/addons
cp -r ./addons.template/kkp ./aws/addons
sed -i 's/TODO_DNS/'"$KKP_DNS"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO@email.com/'"$KKP_USERNAME"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-SECRET/'"$RANDOM_SECRET"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-KUBERMATIC-OAUTH-SECRET-FROM-VALUES.YAML/'"$RANDOM_SECRET"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-ISSUERCOOKIEKEY/'"$ISSUERCOOKIEKEY"'/g' ./aws/addons/kkp/*.yaml
sed -i 's/TODO-A-RANDOM-SERVICEACCOUNTKEY/'"$SERVICEACCOUNTKEY"'/g' ./aws/addons/kkp/*.yaml
```

## Create k8s cluster using kubeone along with KKP master as addon.
```bash
make k1-apply PROVIDER=aws
```

Get the LoadBalancer External IP by following command.
```bash
kubectl get svc -n nginx-ingress-controller
```
> Update DNS mapping with External IP of for nginx ingress controller service. 

Validate the Kubermatic resources and certificates
```bash
kubectl -n kubermatic get deployments,pods
```
```bash
kubectl get certificates -A -w
```
> Wait for while, if still kubermatic-api-xxx pods / kubermatic & dex tls certificates are not in Ready state, delete  and wait to get validated.

## Login to KKP Dashboard

Finally, you should be able to login to KKP dashboard! 

Login to https://$TODO_DNS/ 
> Use username/password configured as part of Kubermatic configuration. 


# Cleanup the setup 

## Destroy the k8s cluster
```bash
make k1-reset PROVIDER=aws
```

## Destroy the AWS infrastructure
```bash
make k1-tf-destroy PROVIDER=aws
```

# Known Open Issues

## FIXME Configuration at Terraform
* Load Balancer configuration to handle single node configuration. 
* Security Group rules for single node configuration. 
* Sequencing of yaml configuration to resolve no match for below no match for crd issue. 
```
unable to recognize "aws/addons/kkp/02_cert-manager.yaml": no matches for kind "ClusterIssuer" in version "cert-manager.io/v1"
unable to recognize "aws/addons/kkp/02_cert-manager.yaml": no matches for kind "ClusterIssuer" in version "cert-manager.io/v1"
unable to recognize "aws/addons/kkp/05_kubermatic-configuration.yaml": no matches for kind "KubermaticConfiguration" in version "operator.kubermatic.io/v1alpha1"
```
