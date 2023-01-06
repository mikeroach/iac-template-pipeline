/* Based on starting point after converting via https://github.com/sl1pm4t/k2tf from:
https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
*/

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"
    }
  }
}

resource "kubernetes_secret_v1" "ingress_nginx_serviceaccount_secret" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    namespace     = "ingress-nginx"
    generate_name = "${kubernetes_service_account_v1.ingress_nginx.metadata.0.name}-token-"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.ingress_nginx.metadata.0.name
    }
    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }
  type = "kubernetes.io/service-account-token"

  wait_for_service_account_token = true
}

resource "kubernetes_service_account_v1" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

}

resource "kubernetes_role" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
  }

  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["ingress-nginx-leader"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "update"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["ingress-nginx-leader"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["list", "watch", "get"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }
}

resource "kubernetes_cluster_role" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "namespaces"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
  }

  rule {
    verbs      = ["list", "watch", "get"]
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
  }
}

resource "kubernetes_role_binding" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx"
  }
}

resource "kubernetes_cluster_role_binding" "ingress_nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name = "ingress-nginx"

    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx"
  }
}

resource "kubernetes_config_map" "ingress_nginx_controller" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  data = {
    allow-snippet-annotations = "true"
  }
}

resource "kubernetes_deployment" "ingress_nginx_controller" {
  depends_on = [
    kubernetes_namespace.ingress_nginx,
    kubernetes_config_map.ingress_nginx_controller,
    kubernetes_service_account_v1.ingress_nginx,
    kubernetes_cluster_role.ingress_nginx,
    kubernetes_role_binding.ingress_nginx,
    kubernetes_cluster_role_binding.ingress_nginx,
  ]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  spec {

    /* With our "highly cost optimized" single-replica hostNetwork-based
    ingress-nginx, upon changes we need to destroy the existing Pod first
    since the new Pod will remain stuck in Pending status as long as the
    old one still has the ports bound. */
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"

        "app.kubernetes.io/instance" = "ingress-nginx"

        "app.kubernetes.io/name" = "ingress-nginx"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"

          "app.kubernetes.io/instance" = "ingress-nginx"

          "app.kubernetes.io/name" = "ingress-nginx"
        }
      }

      spec {
        host_network = true

        container {
          name  = "controller"
          image = "registry.k8s.io/ingress-nginx/controller:v1.5.1@sha256:4ba73c697770664c1e00e9f968de14e08f606ff961c76e5d7033a4a9c593c629"
          args = [
            "/nginx-ingress-controller",
            "--report-node-internal-ip-address",
            "--election-id=ingress-nginx-leader",
            "--controller-class=k8s.io/ingress-nginx",
            "--ingress-class=nginx",
            "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
          ]

          port {
            name           = "http"
            container_port = 80
            host_port      = 80
            protocol       = "TCP"
          }

          port {
            name           = "https"
            container_port = 443
            host_port      = 443
            protocol       = "TCP"
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

          env {
            name  = "LD_PRELOAD"
            value = "/usr/local/lib/libmimalloc.so"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path   = "/healthz"
              port   = "10254"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }

            run_as_user                = 101
            allow_privilege_escalation = true
          }
        }

        termination_grace_period_seconds = 300
        dns_policy                       = "ClusterFirst"

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "ingress-nginx"
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_ingress_class" "nginx" {
  depends_on = [kubernetes_namespace.ingress_nginx]
  metadata {
    name = "nginx"

    labels = {
      "app.kubernetes.io/component" = "controller"

      "app.kubernetes.io/instance" = "ingress-nginx"

      "app.kubernetes.io/name" = "ingress-nginx"

      "app.kubernetes.io/part-of" = "ingress-nginx"

      "app.kubernetes.io/version" = "1.5.1"
    }
  }

  spec {
    controller = "k8s.io/ingress-nginx"
  }
}

resource "kubernetes_ingress_v1" "default-redirect" {
  depends_on = [kubernetes_namespace.ingress_nginx]
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
            service {
              name = "none"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}