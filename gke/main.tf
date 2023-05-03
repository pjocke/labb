resource "google_compute_network" "primary" {
  name                    = "primary"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "maria" {
  name          = "maria-nodes"
  ip_cidr_range = "172.16.8.0/24"
  network       = google_compute_network.primary.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "maria-pods"
    ip_cidr_range = "172.16.0.0/22"
  }

  secondary_ip_range {
    range_name    = "maria-services"
    ip_cidr_range = "172.16.9.0/24"
  }
}

resource "google_compute_subnetwork" "tomas" {
  name          = "tomas-nodes"
  ip_cidr_range = "172.16.10.0/24"
  network       = google_compute_network.primary.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "tomas-pods"
    ip_cidr_range = "172.16.4.0/22"
  }

  secondary_ip_range {
    range_name    = "tomas-services"
    ip_cidr_range = "172.16.11.0/24"
  }
}

resource "google_compute_subnetwork" "joakim" {
  name          = "joakim-nodes"
  ip_cidr_range = "172.16.16.0/24"
  network       = google_compute_network.primary.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "joakim-pods"
    ip_cidr_range = "172.16.12.0/22"
  }

  secondary_ip_range {
    range_name    = "joakim-services"
    ip_cidr_range = "172.16.17.0/24"
  }
}

data "google_compute_zones" "available" {
}

resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes"
  display_name = "GKE service account"
}

resource "google_container_cluster" "maria" {
  name     = "maria"
  location = data.google_compute_zones.available.names.0

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.primary.self_link
  subnetwork = google_compute_subnetwork.maria.self_link

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.maria.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.maria.secondary_ip_range[1].range_name
  }
}

resource "google_container_node_pool" "maria" {
  name       = "maria"
  location   = google_container_cluster.maria.location
  cluster    = google_container_cluster.maria.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_project_iam_member" "maria" {
  project = var.project
  role    = "roles/container.admin"
  member  = "user:maria.franz@knowit.se"
}

resource "google_container_cluster" "tomas" {
  name     = "tomas"
  location = data.google_compute_zones.available.names.0

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.primary.self_link
  subnetwork = google_compute_subnetwork.tomas.self_link

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.tomas.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.tomas.secondary_ip_range[1].range_name
  }
}

resource "google_container_node_pool" "tomas" {
  name       = "tomas"
  location   = google_container_cluster.tomas.location
  cluster    = google_container_cluster.tomas.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_project_iam_member" "tomas" {
  project = var.project
  role    = "roles/container.admin"
  member  = "user:tomas.voulgaris@knowit.se"
}

resource "google_container_cluster" "joakim" {
  name     = "joakim"
  location = data.google_compute_zones.available.names.0

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.primary.self_link
  subnetwork = google_compute_subnetwork.joakim.self_link

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.joakim.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.joakim.secondary_ip_range[1].range_name
  }
}

resource "google_container_node_pool" "joakim" {
  name       = "joakim"
  location   = google_container_cluster.joakim.location
  cluster    = google_container_cluster.joakim.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_project_iam_member" "joakim" {
  project = var.project
  role    = "roles/container.admin"
  member  = "user:joakim.bomelin@knowit.se"
}
