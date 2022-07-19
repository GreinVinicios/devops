#!/usr/bin/env bash
set -euo pipefail

function main() {
  echo 'Starting ...'
  echo 'Adding Helm repo ...'
  repoAdd

  createResources

  echo 'Installing ...'
  install
  
  echo 'Getting default credentials ...'
  echo 'Default user: '
  defaultUsr
  echo 'Default password: '
  defaultPass
}

function repoAdd() {
  helm repo add jenkins https://charts.jenkins.io
  helm repo update
}

function createResources() {
  createNamespace
  createPV
  createCertificate
}

function createNamespace() {
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
EOF
}

function createPV() {
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-disk
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
EOF
}

function createCertificate() {
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: jenkins-certificate
  namespace: jenkins
spec:
  dnsNames:
  - jenkins.viniciosgrein.de
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: jenkins-certificate
EOF
}

function install() {
  helm install jenkins jenkins/jenkins --create-namespace \
  --debug \
  --namespace jenkins \
  -f values.yaml #https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
}

function defaultUsr() {
  jsonpath="{.data.jenkins-admin-user}"
  secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

function defaultPass() {
  jsonpath="{.data.jenkins-admin-password}"
  secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

main
