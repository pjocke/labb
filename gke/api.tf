resource "google_project_service" "api" {
  for_each = toset(var.apis)

  service                    = each.key
  disable_dependent_services = true
  disable_on_destroy         = false
}