resource "google_compute_address" "joakim" {
  for_each = toset(["dashboard", "web"])
  name     = "joakim-${each.key}"
}