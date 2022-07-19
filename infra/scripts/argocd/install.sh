#!/usr/bin/env bash
set -euo pipefail

ARGO_VERSION=4.9.12

function main() {
  echo 'Starting ...'
  echo 'Adding argocd Helm repo ...'
  argoRepoAdd

  echo 'Installing argocd ...'
  install

  echo 'Creating ingress route ...'
  createIngressRouteCRD

  sleep 3m # Need to wait argo be running - it will be changed to a kubectl command checking pod status later
  echo 'Creating ArgoCD application ...'
  createArgoCDApplication

  echo 'ArgoCD password ...'
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
}

function argoRepoAdd() {
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
}

function createIngressRouteCRD() {
cat <<EOF | kubectl apply -f -
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
    - kind: Rule
      match: Host('argocd.viniciosgrein.de')
      priority: 10
      services:
        - name: argocd-server
          port: 80
    - kind: Rule
      match: Host('argocd.viniciosgrein.de') && Headers('Content-Type', 'application/grpc')
      priority: 11
      services:
        - name: argocd-server
          port: 80
          scheme: h2c
  tls:
    certResolver: default
EOF
}

function createArgoCDApplication() {
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  destination:
    name: ''
    namespace: argocd
    server: 'https://kubernetes.default.svc'
  source:
    path: chart
    repoURL: 'https://github.com/GreinVinicios/devops.git'
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
}

function install() {
  helm install argo-cd argo/argo-cd --create-namespace \
  --debug \
  --version ${ARGO_VERSION} \
  --namespace argocd \
  -f values.yaml #https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
}

main
