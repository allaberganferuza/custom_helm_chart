module  "application-namespace" {
    source = "./modules/terraform-k8s-namespace"
    deployment_namespace = var.app_name
}

module "application" {
    source = "./modules/terraform-helm"
    deployment_name = var.app_name
    deployment_namespace = module.application-namespace.namespace
    deployment_path = "charts/application"
    values_yaml = <<EOF

replicaCount: 1

image:
  repository: "${var.repository}"
  tag: "${var.app_version}"

imagePullSecrets: 
  - name: "artifact-registry"

service:
  type: ClusterIP
  port: "${var.app_port}"

ingress:
  enabled: true
  className: "nginx"
  annotations: 
    ingress.kubernetes.io/ssl-redirect: "false"
    cert-manager.io/cluster-issuer: letsencrypt-prod
    acme.cert-manager.io/http01-edit-in-place: "true"
  hosts:
    - host: "${var.app_name}.${var.google_domain_name}"
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: 
    - secretName: "${var.app_name}"
      hosts:
        - "${var.app_name}.${var.google_domain_name}"
EOF
}