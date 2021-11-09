resource "exoscale_network" "sks" {
  zone             = var.zone
  name             = "network-sks"
  display_text     = "Private network for my Kubernetes cluster"
  start_ip = "10.0.0.20"
  end_ip   = "10.0.0.200"
  netmask  = "255.255.255.0"

  tags = {
    environment = "production"
  }
}

resource "exoscale_security_group" "ssh" {
  name = "ssh"
}
resource "exoscale_security_group_rules" "ssh" {
  security_group = exoscale_security_group.ssh.name

  ingress {
    description = "SSH"
    protocol    = "TCP"
    cidr_list   = ["0.0.0.0/0", "::/0"]
    ports       = ["22"]
  }
}

resource "exoscale_security_group" "sks" {
  name = "sks"
}

resource "exoscale_security_group_rules" "sks" {
  security_group = exoscale_security_group.sks.name

  ingress {
    description              = "Calico traffic"
    protocol                 = "UDP"
    ports                    = ["4789"]
    user_security_group_list = [exoscale_security_group.sks.name]
  }

  ingress {
    description = "Kubernetes nodes"
    protocol  = "TCP"
    ports     = ["10250"]
    user_security_group_list = [exoscale_security_group.sks.name]
  }

  ingress {
    description = "NodePort services"
    protocol    = "TCP"
    cidr_list   = ["0.0.0.0/0", "::/0"]
    ports       = ["30000-32767"]
  }
}

resource "exoscale_security_group" "webapp" {
  name = "webapp"
}

resource "exoscale_security_group_rules" "webapp" {
  security_group = exoscale_security_group.webapp.name

  ingress {
    description              = "Open the port 10000"
    protocol                 = "TCP"
    ports                    = ["10000"]
    cidr_list                = ["0.0.0.0/0", "::/0"]
  }
}
