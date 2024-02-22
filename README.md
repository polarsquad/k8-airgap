# k8-airgap

## TO-DO
* script to pull all docker images from a helm-chart, this should be able to have an option to pull and retag and save as tar
* generate a tarball with bootstrap containers (registry,gitea,argocd)
* script to parse a argocd app-of-apps values.yaml and get all helmcharts and container images and generate a tarball that will be used as artifact. 
* script to install the artifact. 