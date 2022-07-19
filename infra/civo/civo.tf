# Kubernetes clister

data "civo_size" "xsmall" {
    filter {
        key = "name"
        values = ["g4s.kube.medium"]
        match_by = "re"
    }
}

resource "civo_kubernetes_cluster" "k8s_devops" {
  name = "k8s_devops"
  applications = ""
  firewall_id = civo_firewall.fw_devops.id
  pools {
    label = "k8s_devops"
    size = element(data.civo_size.xsmall.sizes, 0).name
    node_count = 2
  }
}

resource "civo_firewall" "fw_devops" {
  name = "fw_devops"
  create_default_rules = false
}

resource "civo_firewall_rule" "kubernetes_http" {
  firewall_id = civo_firewall.fw_devops.id
  protocol = "tcp"
  start_port = "80"
  end_port = "80"
  cidr = ["0.0.0.0/0"]
  direction = "ingress"
  action = "allow"
  label = "kubernetes_http"
}

resource "civo_firewall_rule" "kubernetes_https" {
  firewall_id = civo_firewall.fw_devops.id
  protocol = "tcp"
  start_port = "443"
  end_port = "443"
  cidr = ["0.0.0.0/0"]
  direction = "ingress"
  action = "allow"
  label = "kubernetes_https"
}

resource "civo_firewall_rule" "kubernetes_api" {
  firewall_id = civo_firewall.fw_devops.id
  protocol = "tcp"
  start_port = "6443"
  end_port = "6443"
  cidr = ["0.0.0.0/0"]
  direction = "ingress"
  action = "allow"
  label = "kubernetes_api"
}

resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [
    civo_kubernetes_cluster.k8s_devops
  ]
  create_duration = "20s"
}

data "civo_loadbalancer" "traefik_lb" {
  depends_on = [
    helm_release.traefik
  ]

  name = "k8s_devops-traefik-traefik"
}
