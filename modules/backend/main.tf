resource "aws_s3_bucket" "devsecops" {
  bucket        = "michael-devsecops"
  force_destroy = var.force_destroy
  tags          = var.bucket_tags
    versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "tfstate_devsecops" {
  bucket        = "michael-tfstate-devsecops"
  force_destroy = false
  tags          = var.bucket_tags

/*
   lifecycle {
    prevent_destroy = true
  }

  */

    versioning {
    enabled = true
  }
  
}

data "aws_iam_policy_document" "bucket_policy_devsecops" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::194856677704:role/test-role-s3"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.devsecops.bucket}/*"
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::194856677704:role/test-role-s3"]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.devsecops.bucket}"
    ]
  }
}

data "aws_iam_policy_document" "bucket_policy_tfstate_devsecops" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::194856677704:role/test-role-s3"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.tfstate_devsecops.bucket}/*"
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::194856677704:role/test-role-s3"]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.tfstate_devsecops.bucket}"
    ]
  }
}


resource "aws_s3_bucket_policy" "devsecops" {
  bucket = aws_s3_bucket.devsecops.id
  policy = data.aws_iam_policy_document.bucket_policy_devsecops.json
}

resource "aws_s3_bucket_policy" "tfstate_devsecops" {
  bucket = aws_s3_bucket.tfstate_devsecops.id
  policy = data.aws_iam_policy_document.bucket_policy_tfstate_devsecops.json
}

resource "aws_s3_bucket_public_access_block" "public_access_block_tfstate_devsecops" {
  bucket = aws_s3_bucket.tfstate_devsecops.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block_devsecops" {
  bucket = aws_s3_bucket.devsecops.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

