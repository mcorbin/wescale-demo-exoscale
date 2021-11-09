terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.30.0"
    }
  }
}

provider "exoscale" {
  key = ""
  secret = ""
}
