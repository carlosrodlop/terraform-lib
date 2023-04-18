resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

#https://artifacthub.io/packages/helm/deliveryhero/node-problem-detector
resource "helm_release" "this" {
  depends_on = [kubernetes_namespace.this]

  chart      = "node-problem-detector"
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://charts.deliveryhero.io/"
  version    = var.chart_version
}
