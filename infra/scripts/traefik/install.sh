#!/usr/bin/env bash
set -euo pipefail

function main() {
  echo 'Starting ...'
  echo 'Adding Helm repo ...'
  repoAdd

  echo 'Installing ...'
  install

  dashBoard
}

function repoAdd() {
  helm repo add traefik https://helm.traefik.io/traefik
  helm repo update
}

function dashBoard() {
cat <<EOF | kubectl apply -f -
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.viniciosgrein.de`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOF
}

function install() {
  helm install traefik traefik/traefik \
  --set ingressClass.enabled=true \
  --set ingressClass.isDefaultClass=true \
  --set ports.web.redirectTo=websecure \
  --set ports.websecure.tls.enabled=true \
  --namespace traefik \
  --create-namespace \
  -f values.yaml #https://raw.githubusercontent.com/traefik/traefik-helm-chart/master/traefik/values.yaml
}

main
