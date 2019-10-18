/* Adapted from https://kubernetes.github.io/ingress-nginx/deploy/ ->
https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.26.1/deploy/static/mandatory.yaml */

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
}

resource "kubernetes_config_map" "nginx-configuration" {
  depends_on = ["kubernetes_namespace.ingress-nginx"]
  metadata {
    name      = "nginx-configuration"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
}

resource "kubernetes_config_map" "tcp-services" {
  depends_on = ["kubernetes_namespace.ingress-nginx"]
  metadata {
    name      = "tcp-services"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
}

resource "kubernetes_config_map" "udp-services" {
  depends_on = ["kubernetes_namespace.ingress-nginx"]
  metadata {
    name      = "udp-services"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
}

resource "kubernetes_service_account" "nginx-ingress-serviceaccount" {
  depends_on = ["kubernetes_namespace.ingress-nginx"]
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }
}

resource "kubernetes_cluster_role" "nginx-ingress-clusterrole" {
  depends_on = ["kubernetes_service_account.nginx-ingress-serviceaccount"]
  metadata {
    name = "nginx-ingress-clusterrole"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}

resource "kubernetes_role" "nginx-ingress-role" {
  depends_on = ["kubernetes_service_account.nginx-ingress-serviceaccount"]
  metadata {
    name      = "nginx-ingress-role"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-controller-leader-nginx"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "nginx-ingress-role-nisa-binding" {
  depends_on = ["kubernetes_service_account.nginx-ingress-serviceaccount"]
  metadata {
    name      = "nginx-ingress-role-nisa-binding"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "nginx-ingress-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "nginx-ingress-serviceaccount"
    namespace = "ingress-nginx"
  }

}

resource "kubernetes_cluster_role_binding" "nginx-ingress-clusterrole-nisa-binding" {
  depends_on = ["kubernetes_service_account.nginx-ingress-serviceaccount"]
  metadata {
    name = "nginx-ingress-clusterrole-nisa-binding"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "nginx-ingress-clusterrole"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "nginx-ingress-serviceaccount"
    namespace = "ingress-nginx"
  }

}

resource "kubernetes_deployment" "nginx-ingress-controller" {
  depends_on = [
    "kubernetes_namespace.ingress-nginx",
    "kubernetes_config_map.nginx-configuration",
    "kubernetes_config_map.tcp-services",
    "kubernetes_config_map.udp-services",
    "kubernetes_service_account.nginx-ingress-serviceaccount",
    "kubernetes_cluster_role.nginx-ingress-clusterrole",
    "kubernetes_role.nginx-ingress-role",
    "kubernetes_role_binding.nginx-ingress-role-nisa-binding",
    "kubernetes_cluster_role_binding.nginx-ingress-clusterrole-nisa-binding",
  ]
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        "app.kubernetes.io/name"    = "ingress-nginx"
        "app.kubernetes.io/part-of" = "ingress-nginx"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"    = "ingress-nginx"
          "app.kubernetes.io/part-of" = "ingress-nginx"
        }
        annotations = {
          "prometheus.io/port"   = "10254"
          "prometheus.io/scrape" = "true"
        }
      }

      spec {
        automount_service_account_token  = true
        host_network                     = true
        termination_grace_period_seconds = "300"
        service_account_name             = "nginx-ingress-serviceaccount"

        container {
          name  = "nginx-ingress-controller"
          image = "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1"

          args = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/nginx-configuration",
            "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
            "--udp-services-configmap=$(POD_NAMESPACE)/udp-services",
            "--publish-service=$(POD_NAMESPACE)/ingress-nginx",
            "--annotations-prefix=nginx.ingress.kubernetes.io"
          ]

          security_context {
            allow_privilege_escalation = true
            privileged                 = false
            run_as_user                = "33"

            capabilities {
              drop = ["all"]
              add  = ["NET_BIND_SERVICE"]
            }
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            name           = "http"
            container_port = "80"
            host_port      = "80"
          }

          port {
            name           = "https"
            container_port = "443"
            host_port      = "443"
          }

          liveness_probe {
            failure_threshold     = "3"
            initial_delay_seconds = "10"
            period_seconds        = "10"
            success_threshold     = "1"
            timeout_seconds       = "10"

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }
          }

          readiness_probe {
            failure_threshold = "3"
            period_seconds    = "10"
            success_threshold = "1"
            timeout_seconds   = "10"

            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "default-redirect" {
  depends_on = ["kubernetes_deployment.nginx-ingress-controller"]
  metadata {
    name      = "default-redirect"
    namespace = "ingress-nginx"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/permanent-redirect" = "https://github.com/mikeroach/"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "none"
            service_port = "80"
          }
        }
      }
    }
  }
}