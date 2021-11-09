resource "exoscale_sks_cluster" "wescale" {
  zone    = var.zone
  name    = "wescale"
  description = "my demo cluster"
  version = "1.22.2"
  auto_upgrade = true

  labels = {
    environment = "production"
  }
}

resource "exoscale_affinity" "sks-nodepool" {
  name        = "sks-nodepool-wescale"
  description = "anti affinity for my sks nodes"
  type        = "host anti-affinity"
}

resource "exoscale_sks_nodepool" "my-first-nodepool" {
  zone               = var.zone
  cluster_id         = exoscale_sks_cluster.wescale.id
  name               = "first-nodepool"
  instance_type      = "standard.medium"
  size               = 3
  disk_size          = 50
  security_group_ids = [exoscale_security_group.sks.id]
  private_network_ids = [exoscale_network.sks.id]
  anti_affinity_group_ids = [exoscale_affinity.sks-nodepool.id]
  instance_prefix  = "wescale"

  labels = {
    environment = "production"
  }
}
