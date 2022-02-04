# Get started with KKP - “KKP on single node K1”

KKP Master setup on a single master/worker k8s node using Kubeone. Leveraging the kubeone addons capability for this implementation.


In this **Get Started with KKP** guide, we will be using AWS Cloud as our underlying infrastructure and KKP release v2.18.4.

> For more information on the kubeone configurations for different enviornemnt, checkout the [Creating the kubernetes Cluster using Kubeone](https://docs.kubermatic.com/kubeone/master/tutorials/creating_clusters/) documentation.

The [kubermatic/kkp-on-node](https://github.com/kubermatic/kkp-on-node) contains the required configuration to install KKP on single node k8s with kubeone. Clone or download it, so that you deploy KKP quickly as per the following instructions and get started with it!  

## Configure the Enviornment

```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxx
```

## Create the Infrastructure using Terraform
```bash
eval `ssh-agent`
ssh-add /path/to/.ssh/id_rsa
make k1-tf-apply PROVIDER=aws
```
> Update the terraform.tfvars with required values such as `cluster_name`, `ssh_public_key_file`, `ssh_private_key_file`.

> **Important**: Add `untaint` flag with value as `true` in the `output.tf` file as shown below
```bash
output "kubeone_hosts" {
  description = "Control plane endpoints to SSH to"

  value = {
    control_plane = {
      untaint              = true
```

## Prepare the KKP addon configuration
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

## Create k8s cluster using kubeone along with KKP master as an addon.
```bash
make k1-apply PROVIDER=aws
```

## Configure the Cluster access
```bash
export KUBECONFIG=$PWD/aws/<cluster_name>-kubeconfig
```

## Validate the KKP Master setup

Get the LoadBalancer External IP by following command.
```bash
kubectl get svc -n ingress-nginx
```
> Update DNS mapping with External IP of for nginx ingress controller service. 

Verify the Kubermatic resources and certificates
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

* Nginx Ingress Controller Load Balancer configuration - Add the node to backend pool manually.
> Should be supported in future as part of Feature request[#1822](https://github.com/kubermatic/kubeone/issues/1822)
