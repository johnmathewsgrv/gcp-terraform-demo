provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "demo_bucket" {
  name          = "${var.env}-demo-bucket-${var.project_id}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true    # ← ADD THIS LINE

  labels = {
    environment = var.env
    managed_by  = "terraform"
  }
}
