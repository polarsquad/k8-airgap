# k8-airgap

This is an Ansible playbook to initialize and deploy de K8 cluster with airgap requirments. It will download all artifacts from a jumper that does have access to the internet and to the airgap vms. 

Artifacts that will be download by the playbook:
* rke2 binary
* bootstrap helm charts saved as tar
    - gitea
    - longhorn
    - argocd
* Container Images saved as tar
* Helm Charts post boostrap which will be deploy by ArgoCD

Base on the Inventory file it is able to config a multi node cluster, a template for this inventory file has been provided: ```ansible/inventory.ini.template```, modify as needed, add or remove vms. Until now this ansible playbook has only beend tested with 3 master nodes and 2 agents. 

As well in ```/artifacts/rke2/nodes/<hostname>``` you will find example of the config.yaml required by RKE2 to config each node, make sure to use the hostname of each vm as folder name for each config file. 

### Steps
1. Download bootstrap helm charts as tar specify under the var ```helmCharts```
2. Download all helm charts used under /argocd/manifest/argo-cd-helm-chart/values.yaml
3. it will continue to use helm template against each tar to get the available list of container images to pull and save as tar, container images as well can be added as part of the var ```docker_images``` 


Apply the whole playbook with this command: 

```ansible-playbook -i inventory.ini rke2.yml```

To Sync helm charts added to the argocd value file use the tag : airgap-values ```ansible-playbook -i inventory.ini rke2.yml --tags airgap-values```


## Requirements
List of Requirment to run and ansible playbook
* inventory.ini file
* config.yaml file for each node inside ```/artifacts/rke2/nodes/<hostname>```
##### Tools
* yq (v4.41.1)
* ansible (2.16.3)
* helm (v3.13.3)

For testing porpuse yyou could use this Env Var to skip accepting the fingerprint from each host

```export ANSIBLE_HOST_KEY_CHECKING=False```

#### Optional Requirements 
If planning to use Opentofu to spin up some vm in aws 
* terragrunt (0.54.22)
* opentofu (v1.6.1)

Environment Variables required to run terrgrunt

* ```export TERRAGRUNT_TFPATH=tofu``` 
* ```export TF_VAR_public_ip="x.x.x.x/32"``` your public Ip to add as a whitelist IP in the security group of the nodes 



     
