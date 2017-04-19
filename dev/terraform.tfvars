# Override lock id and remote_state key to make them more distinct. While we
# want shared production and stage environments, we don't want to share dev or
# testing environments.
#
# NOTE: the calculated values here MUST match the value var.environment or
# data.terraform_remote_state for data passing will not work.
terragrunt = {
  lock {
    backend = "dynamodb"
    config {
      # We're one level lower in the hierarchy, so add that back to the
      # beginning.
      state_file_id = "dev/${path_relative_to_include()}"
    }
  }

  remote_state {
    backend = "s3"
    config {
      encrypt = "true"
      bucket = "gpii-terraform-state"
      # We're one level lower in the hierarchy, so add that back to the
      # beginning.
      key = "dev/${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
    }
  }
}
