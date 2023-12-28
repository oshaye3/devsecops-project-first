
################################################################################
# S3
################################################################################


variable "force_destroy" {
  description = "Delete all objects from the bucket without error"
  type        = bool
  default     = true #SET TO FALSE IN PROD!!
}

variable "bucket_tags" {
  description = "Tags to assign to bucket"
  type        = map(string)
  default     = {}
}

/*
variable "bucket_names" {
  description = "Names of S3 buckets"
  type        = list(string)
}
*/