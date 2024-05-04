terraform {
  backend "gcs" {
    bucket  = "kserghei-secret"
    prefix  = "terraform/state"
  }
}


module "github_repository" {
  source                   = "github.com/kserghei2103/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux0"
}

module "tls_private_key" {
  source = "github.com/kserghei2103/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}

module "kind_cluster" {
  source = "github.com/kserghei2103/tf-kind-cluster?ref=cert_auth"
}

module "flux_bootstrap" {
  source            = "github.com/kserghei2103/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_host       = module.kind_cluster.endpoint
  config_client_key = module.kind_cluster.client_key
  config_ca         = module.kind_cluster.ca
  config_crt        = module.kind_cluster.crt
  github_token      = var.GITHUB_TOKEN
}

