data "exoscale_compute_template" "debian" {
  zone = var.zone
  name = "Linux Debian 11 (Bullseye) 64-bit"
}

resource "exoscale_instance_pool" "instance-pool-example" {
  zone         = var.zone
  name         = "example-instance-pool"
  template_id  = data.exoscale_compute_template.debian.id
  size         = 2
  disk_size    = 30
  key_pair     = "dell"

  security_group_ids = [exoscale_security_group.ssh.id, exoscale_security_group.webapp.id]
  instance_type = "standard.medium"
  network_ids = [exoscale_network.sks.id]

  labels = {
    ansible_groups = "webapps"
  }
}

resource "exoscale_nlb" "website" {
  zone = var.zone
  name = "webapp"
  description = "This is the Network Load Balancer for my webapp"

  labels = {
    environment = "prod"
  }
}

resource "exoscale_nlb_service" "website" {
  zone             = exoscale_nlb.website.zone
  name             = "http"
  description      = "HTTP endpoint"
  nlb_id           = exoscale_nlb.website.id
  instance_pool_id = exoscale_instance_pool.instance-pool-example.id
  protocol         = "tcp"
  port             = 80
  target_port      = 10000
  strategy         = "round-robin"

  healthcheck {
    mode     = "http"
    port     = 10000
    uri      = "/healthz"
    interval = 5
    timeout  = 3
    retries  = 1
  }
}
