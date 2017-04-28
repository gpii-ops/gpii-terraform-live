terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket = "gpii-terraform-state"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
      encrypt = true

      # Tell Terraform to do locking using DynamoDB. Terragrunt will
      # automatically create this table for you if it doesn't already exist.
      ### lock_table = "gpii-terraform-lock-table_${path_relative_to_include()}"
      lock_table = "gpii-terraform-lock-table"
    }
  }
}
