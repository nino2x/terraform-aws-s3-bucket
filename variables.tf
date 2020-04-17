variable "name" {
  type = string
}

variable "versioning" {
  type    = bool
  default = false
}

variable "logging" {
  type    = bool
  default = false
}

variable "object_lifecycle" {
  type    = bool
  default = false
}

variable "object_replication" {
  type    = bool
  default = false
}

variable "encryption" {
  type    = bool
  default = false
}

variable "create_rw_iam_user" {
  type    = bool
  default = false
}
