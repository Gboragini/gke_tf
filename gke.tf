# Algumas variáveis extras
variable "gke_username" {
  default     = "PlacaCentral"
  description = "user_gke"
}

variable "gke_password" {
  default     = "Kubeteste123456789*"
  description = "password_gke"
}

variable "gke_num_nodes" {
  default     = 1
  description = "numero de nodes para o cluster"
}

# Configurações do cluster
resource "google_container_cluster" "wpteste" {
  name     = sensitive("${var.project_id}-gke")
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

}

# Node Pool Gerenciado Separadamente
resource "google_container_node_pool" "nodes_primarios" {
  name       = "${google_container_cluster.wpteste.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.wpteste.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = sensitive(var.project_id)
    }

    machine_type = "n2-standard-2ter"
    tags         = ["gke-node", sensitive("${var.project_id}-gke")]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}