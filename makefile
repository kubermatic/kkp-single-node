########## K8s cluster
K1_CONFIG="./${PROVIDER}"
TF_CONFIG="./terraform"    #relative from K1_CONFIG

######### KubeOne
k1-load-env:
	test -d ${K1_CONFIG} && echo "[ok]" && echo "kubeone config folder found"
	cd ${K1_CONFIG} && test -f ${K1_SSH_KEY} && chmod 600 ${K1_SSH_KEY} && eval `ssh-agent` && ssh-add ${K1_SSH_KEY} && echo "[ok] "|| echo "ssh key permission ..."

k1-tf-init:
	cd ${K1_CONFIG} && cd ${TF_CONFIG} && \
	terraform init

k1-tf-apply: k1-load-env k1-tf-init
	cd ${K1_CONFIG} && cd ${TF_CONFIG} && \
	terraform apply --auto-approve

k1-tf-destroy: k1-load-env
	cd ${K1_CONFIG} && cd ${TF_CONFIG} && \
	terraform destroy --auto-approve

k1-tf-refresh: k1-load-env
	cd ${K1_CONFIG} && cd ${TF_CONFIG} && \
	terraform refresh

k1-apply: k1-load-env
	cd ${K1_CONFIG} && kubeone apply -m kubeone.yaml -t ${TF_CONFIG} --verbose --auto-approve

k1-reset: k1-load-env
	cd ${K1_CONFIG} && kubeone reset -m kubeone.yaml -t ${TF_CONFIG}  --verbose --auto-approve

k1-apply-addons: k1-load-env
	kubectl apply -f ${K1_CONFIG}/addons
