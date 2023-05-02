variable "project" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = "europe-north1"
}

variable "apis" {
  type    = list(any)
  default = []
}
