output "website_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.static-site.name}/${google_storage_bucket.static-site.website[0].main_page_suffix}"
  description = "The public web URL to test your static website"
}

output "vpc_name" {
  value       = google_compute_network.vpc_network.self_link
  description = "The self link of the VPC network"
}

# output "gcs_native_url" {
#   value       = google_storage_bucket.static-site.content_uri
#   description = "The native GCS URI for the bucket"
# }