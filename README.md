---

# k8-airgap

This is an Ansible playbook to initialize and deploy a K8 cluster with airgap requirements. It will download all artifacts from a jumper that has access to the internet and to the airgap VMs.

Artifacts that will be downloaded by the playbook:
- rke2 binary
- bootstrap helm charts saved as tar
  - gitea
  - longhorn
  - argocd
- Container Images saved as tar
- Helm Charts post bootstrap which will be deployed by ArgoCD

Based on the Inventory file, it is able to configure a multi-node cluster. A template for this inventory file has been provided: `ansible/inventory.ini.template`. Modify as needed, add or remove VMs. Until now, this Ansible playbook has only been tested with 3 master nodes and 2 agents.

Also, in `/artifacts/rke2/nodes/<hostname>`, you will find examples of the `config.yaml` required by RKE2 to configure each node. Make sure to use the hostname of each VM as the folder name for each config file.

### Steps
1. Download bootstrap helm charts as tar specified under the var `helmCharts`.
2. Download all helm charts used under `/argocd/manifest/argo-cd-helm-chart/values.yaml`.
3. Use helm template against each helm chart tar to get the available list of container images to pull and save as tar. Container images as well can be added as part of the var `docker_images`.
4. Pull Container Image from var `docker_images` and store them in `ansible/rke2/bootstrap/images`.
5. Replace values from the argo-cd-helm-chart `values.yaml` to provide an airgap path, meaning use the Gitea repo instead of the public repository of helm chart and use the master branch instead of version.
6. Archive the repo `argocd/manifest`.
7. Download RKE2 artifacts.
8. Upload all artifacts to each node, especially the container image artifacts as RKE2 imports all tars that are under `/var/lib/rancher/rke2/agent/images/`. With this, we avoid the need for having a registry and retagging each container image, and replacing this in the `values.yaml` of the apps of app helm chart.
9. Install RKE2 in master nodes one at a time.
10. Install RKE2 in agents in parallel.
11. Install Longhorn, as our storage class.
12. Install Gitea, as our repository where we will store an apps of app helm chart and use ArgoCD to deploy it.
13. Install ArgoCD, as our airgap CD, which will read Gitea hosted in the same cluster as the source of truth.

Apply the whole playbook with this command:

```
ansible-playbook -i inventory.ini rke2.yml
```

To Sync helm charts added to the ArgoCD value file, use the tag: `airgap-values`

```
ansible-playbook -i inventory.ini rke2.yml --tags airgap-values
```

## Requirements
List of Requirements to run an Ansible playbook:
- inventory.ini file
- config.yaml file for each node inside `/artifacts/rke2/nodes/<hostname>`

##### Tools
- yq (v4.41.1)
- ansible (2.16.3)
- helm (v3.13.3)

For testing purposes, you could use this Environment Variable to skip accepting the fingerprint from each host:

```
export ANSIBLE_HOST_KEY_CHECKING=False
```

#### Optional Requirements 
If planning to use Opentofu to spin up some VMs in AWS:
- terragrunt (0.54.22)
- opentofu (v1.6.1)

Environment Variables required to run terragrunt:

```
export TERRAGRUNT_TFPATH=tofu
export TF_VAR_public_ip="x.x.x.x/32"
```
Your public IP to add as a whitelist IP in the security group of the nodes.

---
