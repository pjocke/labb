resource "google_dns_managed_zone" "knowitlia_cloud" {
  name     = "knowitlia-cloud"
  dns_name = "knowitlia.cloud."

  dnssec_config {
    state = "off"
  }
}

resource "google_dns_record_set" "test" {
  name = "test.${google_dns_managed_zone.knowitlia_cloud.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.knowitlia_cloud.name

  rrdatas = ["1.1.1.1"]
}