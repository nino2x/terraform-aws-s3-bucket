provider "aws" {
  version = "~> 2.56"
  region  = "eu-central-1"

  #  assume_role {
  #    role_arn    = "arn:aws:iam::XXXXXXXXXXXX:role/CrossAccountRole"
  #    external_id = "PLACEHOLDER"
  #  }
}

module "bucket" {
  source = "../."

  name               = "terraform-ac3febec-1d0a-49d9-a1c0-329476ce45af"
  versioning         = true
  logging            = true
  object_lifecycle   = true
  object_replication = true
  encryption         = true
  create_rw_iam_user = true
}
