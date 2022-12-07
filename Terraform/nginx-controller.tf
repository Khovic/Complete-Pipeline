module "nginx-controller" {
  name    = "nginx-controller"
  source  = "terraform-iaac/nginx-controller/helm"
  version = "2.0.5"
}
