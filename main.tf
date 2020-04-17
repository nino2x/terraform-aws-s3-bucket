locals {
  logging_bucket_name = "${var.name}-logs"
  replica_bucket_name = "${var.name}-replica"

  bucket_list = concat(
    [var.name],
    var.logging ? [local.logging_bucket_name] : [],
    var.object_replication ? [local.replica_bucket_name] : []
  )
}

resource "aws_s3_bucket" "main" {
  bucket = var.name
  acl    = "private"

  dynamic "versioning" {
    for_each = var.versioning ? [{}] : []
    content {
      enabled = true
    }
  }

  dynamic "logging" {
    for_each = var.logging ? [{}] : []
    content {
      target_bucket = aws_s3_bucket.logging[0].id
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.object_lifecycle ? [{}] : []
    content {
      id      = "all"
      enabled = true

      transition {
        days          = 30
        storage_class = "ONEZONE_IA"
      }

      expiration {
        days = 90
      }

      noncurrent_version_expiration {
        days = 14
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.object_replication ? [{}] : []
    content {
      role = aws_iam_role.replication[0].arn

      rules {
        id     = "all"
        status = "Enabled"

        destination {
          bucket        = aws_s3_bucket.replication[0].arn
          storage_class = "STANDARD"
        }
      }
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption ? [{}] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}

resource "aws_s3_bucket" "logging" {
  count = var.logging ? 1 : 0

  bucket = local.logging_bucket_name
  acl    = "log-delivery-write"

  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption ? [{}] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}

resource "aws_s3_bucket" "replication" {
  count = var.object_replication ? 1 : 0

  bucket = local.replica_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption ? [{}] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}

resource "aws_iam_role" "replication" {
  count = var.object_replication ? 1 : 0

  name = join("-", ["tf-replication-role", substr(var.name, 0, 16)])

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy" "replication" {
  count = var.object_replication ? 1 : 0

  name = join("-", ["tf-replication-policy", substr(var.name, 0, 16)])

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration"
        ],
        "Resource": [
          "${aws_s3_bucket.main.arn}"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl"
        ],
        "Resource": [
          "${aws_s3_bucket.main.arn}/*"
        ],
        "Effect": "Allow"
      },
      {
        "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ],
        "Resource": [
          "${aws_s3_bucket.replication[0].arn}/*"
        ],
        "Effect": "Allow"
      }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.object_replication ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_iam_user" "main" {
  count = var.create_rw_iam_user ? 1 : 0

  name          = "s3-rw-${var.name}"
  force_destroy = true
}

resource "aws_iam_user_policy" "main" {
  count = var.create_rw_iam_user ? 1 : 0

  name = "rw-bucket-access"
  user = aws_iam_user.main[0].name

  policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource": ["${join("\", \"", formatlist("arn:aws:s3:::%s", local.bucket_list))}"],
        "Effect": "Allow"
      },
      {
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject"
        ],
        "Resource": ["${join("\", \"", formatlist("arn:aws:s3:::%s/*", local.bucket_list))}"],
        "Effect": "Allow"
      }
    ]
  }
  POLICY
}
