variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "istio_namespace" {
  description = "Namespace where Istio is installed"
  type        = string
  default     = "istio-system"
}

variable "app_namespace" {
  description = "Namespace for the demo app and gateway"
  type        = string
  default     = "team-divider"
}
