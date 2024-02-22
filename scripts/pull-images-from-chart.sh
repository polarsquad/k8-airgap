#!/bin/bash
set -x
helm template gitea-charts/gitea | yq -rN '..|.image? | select(.)' | sort | uniq | xargs -I {} bash -c 'docker save {} | gzip > ../ansible/artifacts/rke2/bootstrap/images/$(echo {} | sed "s/[\.\/]/-/g").tar.gz '

