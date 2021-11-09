
resource "exoscale_database" "pg_prod" {
  zone = var.zone
  name = "pg-example"
  type = "pg"
  plan = "startup-4"

  termination_protection = false

  pg {
    version = "13"
    backup_schedule = "04:00"

    ip_filter = [
      "0.0.0.0/0",
    ]

    pg_settings = jsonencode({
      timezone: "Europe/Zurich"
    })
  }
}
