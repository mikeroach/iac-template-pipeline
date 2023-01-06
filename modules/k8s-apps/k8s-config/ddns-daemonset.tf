/* In the interest of Smart Spending ®™ for this shoestring budget
environment, ensure that our single node Nginx ingress controller's
ephemeral external IP address is registered to its corresponding DNS
hostname. Remember to target this to a pod/ingress-specific single
node pool when adding support for multi-node/pool K8s clusters.

I wonder if I can use the Downward API to determine external IPs
instead of depending on ifconfig.co? */

resource "kubernetes_daemonset" "gandi_ddns" {
  metadata {
    name      = "gandi-ddns"
    namespace = "kube-system"
    labels = {
      k8s-app = "gandi-ddns"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "gandi-ddns"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "gandi-ddns"
        }
      }

      spec {
        container {
          /* Incredibly, none of the first dozen or so library images I tried
          had built-in curl - so I used the first Alpine-based community
          image I could find. TODO: Make my own minimal curl image. */
          image = "pstauffer/curl:v1.0.3"
          name  = "gandi-ddns"

          command = ["/bin/sh"]
          args = [
            "-c",
            <<EOF
            set -xe
            while : ; do
             date
             IP=`curl -s ifconfig.co`
             curl -s -X PUT -H "Content-Type: application/json" \
             -H "X-Api-Key: $${GANDI_API_KEY}" \
             -d "{\"rrset_ttl\": 300, \"rrset_values\": [\"$${IP}\"]}" \
             "https://dns.api.gandi.net/api/v5/domains/$${DOMAIN}/records/$${HOSTNAME}/A" ;
              date
              sleep 300
            done
            EOF
          ]

          env {
            name  = "GANDI_API_KEY"
            value = var.gandi_api_key
          }

          env {
            name  = "DOMAIN"
            value = var.dns_domain
          }

          env {
            name  = "HOSTNAME"
            value = var.gcp_project_shortname
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "5Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "5Mi"
            }
          }

        }
      }
    }
  }
}