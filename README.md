# AWS S3 Terraform module

Creates an S3 bucket with additional optional features.

## Terraform versions

Requires Terraform version `>=0.12`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Bucket name. Must be globally unique. Other resources derive names from this variable. | `string` | n/a | yes |
| versioning | Turns on object versioning. | `bool` | `false` | no |
| logging | Turns on server access logging and creates a logging bucket. | `bool` | `false` | no |
| object_lifecycle | Turns on object lifecycle rule with fixed values. | `bool` | `false` | no |
| object_replication | Turns on object replication and creates a replication bucket in the same region. | `bool` | `false` | no |
| encryption | Turns on server side object encryption. This includes replication and logging buckets if they're enabled. | `bool` | `false` | no |
| create\_rw\_iam\_user | Creates IAM user with read/write access to the bucket. This includes logging and replication buckets if they exist. | `bool` | `false` | no |

