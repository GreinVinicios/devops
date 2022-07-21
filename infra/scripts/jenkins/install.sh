#!/usr/bin/env bash
set -euo pipefail

function main() {
  echo 'Starting ...'
  echo 'Adding Helm repo ...'
  repoAdd

  #createResources

  echo 'Installing ...'
  install
  createCertificate

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
  #createNamespace
  #createPV
  createCertificate
}

function createNamespace() {
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: jenkinsci
EOF
}

function createPV() {
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkinsci-disk
  namespace: jenkinsci
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
  name: jenkinsci-certificate
  namespace: jenkinsci
spec:
  dnsNames:
  - jenkinsci.viniciosgrein.de
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: jenkinsci-certificate
EOF
}

function install() {
  helm install jenkinsci jenkins/jenkins \
  --create-namespace \
  --namespace jenkinsci \
  --set controller.image=greinvinicios/jenkins-custom \
  --set controller.tag=1.0.0 \
  -f values.yaml
  #https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
}

function defaultUsr() {
  jsonpath="{.data.jenkins-admin-user}"
  secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

function defaultPass() {
  kubectl exec --namespace jenkinsci -it svc/jenkinsci -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
}

main
