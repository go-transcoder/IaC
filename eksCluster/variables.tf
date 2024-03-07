variable "vpc_id" {
  description = "The vpc id to be used with the cluster"
  type        = string
}

variable "vpc_subnets" {
  description = "The subnets to be used by the cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  type        = any
}

variable "oidc_fully_qualified_subjects" {
  type        = list(string)
  description = "Specifies which Kubernetes service accounts are allowed to assume the IAM role via OIDC authentication"
  default     = [
    "system:serviceaccount:default:transcoder-app"
  ]
}

variable "service_account" {
  description = "The service account that is gonna be used with the pods for the uploader app"
  type        = string
  default     = "transcoder-app"
}

variable "region" {
  description = "region in which we are hosting eks"
  type        = string
}
