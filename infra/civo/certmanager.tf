resource "kubernetes_namespace" "certmanager" {
  depends_on = [
    time_sleep.wait_for_kubernetes
  ]

  metadata {
    name = "certmanager"
  }
}

resource "helm_release" "certmanager" {
  depends_on = [
    kubernetes_namespace.certmanager
  ]

  name      = "certmanager"
  namespace = "certmanager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  # Kubernetes CRDs
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_certmanager" {
  depends_on = [
    helm_release.certmanager
  ]
  create_duration = "10s"
}

resource "kubectl_manifest" "letsencrypt_prod" {
  depends_on = [
    time_sleep.wait_for_certmanager
  ]

  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: vinicios.grein@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
    - dns01:
        cloudflare:
          email: vinicios.grein@gmail.com
          apiKeySecretRef:
            name: cloudflare-api-key-secret
            key: api-key
    YAML
}

resource "time_sleep" "wait_for_clusterissuer" {
  depends_on = [
    kubectl_manifest.letsencrypt_prod
  ]

  create_duration = "30s"
}
