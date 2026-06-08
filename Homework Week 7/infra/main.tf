resource "google_storage_bucket" "static-site" {
  name          = "susanoo-static-site"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  public_access_prevention = "inherited"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
#   cors {
#     origin          = ["http://image-store.com"]
#     method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
#     response_header = ["*"]
#     max_age_seconds = 3600
#   }
#   cors {
#     origin            = ["http://image-store.com"]
#     method            = ["GET", "HEAD", "PUT", "POST", "DELETE"]
#     response_header   = ["*"]
#     max_age_seconds   = 0
#   }
}
######           Public Users Read Permissions

resource "google_storage_bucket_iam_binding" "public_rule" {
  bucket = google_storage_bucket.static-site.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}



#######       Uploading to the bucket with correct content types

resource "google_storage_bucket_object" "index" {
  name         = "index.html"
  bucket       = google_storage_bucket.static-site.name
  source       = "${path.module}/assets/index.html"
  content_type = "text/html" 
}

resource "google_storage_bucket_object" "not_found" {
  name         = "404.html"
  bucket       = google_storage_bucket.static-site.name
  source       = "${path.module}/assets/404.html"
  content_type = "text/html" 
}

resource "google_storage_bucket_object" "avatar" {
  name         = "avatar.png"
  bucket       = google_storage_bucket.static-site.name
  source       = "${path.module}/assets/avatar.png"
  content_type = "image/png" 
}

resource "google_storage_bucket_object" "image" {
  name         = "style.css"
  bucket       = google_storage_bucket.static-site.name
  source       = "${path.module}/assets/style.css"
  content_type = "text/css"  
}










resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}