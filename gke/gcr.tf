resource "google_container_registry" "primary" {
  location = "EU"
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.primary.id
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.kubernetes.email}"
}
