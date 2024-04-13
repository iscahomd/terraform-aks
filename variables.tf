variable "cluster_name" {
  description = <<-EOT
    The name of the Managed Kubernetes Cluster to create.
    Changing this forces a new resource to be created.
  EOT
  type        = string
  default     = "SINGLE_AKS"
}

variable "resource_group_name" {
  description = <<-EOT
    Specifies the Resource Group where the Managed Kubernetes Cluster should exist.
    Changing this forces a new resource to be created.
  EOT
  type        = string
  default     = "SINGLE_AKS_MY_RG"
}

variable "location" {
  description = <<-EOT
    The location where the Managed Kubernetes Cluster should be created.
    Changing this forces a new resource to be created.
  EOT
  type        = string
  default     = "northcentralus"
}
