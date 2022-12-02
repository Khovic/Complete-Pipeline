module "nginx-controller" {
  name    = "nginx-2"
  source  = "terraform-iaac/nginx-controller/helm"
  version = "2.0.5"
}
