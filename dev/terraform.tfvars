# Override lock id and remote_state key to make them more distinct. While we
# want shared production and stage environments, we don't want to share dev or
# testing environments.
#
# NOTE: the hardcoded var.environment value (e.g. "dev") MUST match in all
# included terragrunt stanzas. This means the var.environment value MUST match
# the name of the environment on disk since this value is used in calculating
# paths elsewhere.
terragrunt = {
  lock {
    backend = "dynamodb"
    config {
      # We're one level lower in the hierarchy, so add that back to the
      # beginning.
      state_file_id = "dev-${get_env("USER", "unknown-user")}/${path_relative_to_include()}"
    }
  }

  remote_state {
    backend = "s3"
    config {
      encrypt = "true"
      bucket = "gpii-terraform-state"
      # We're one level lower in the hierarchy, so add that back to the
      # beginning.
      key = "dev-${get_env("USER", "unknown-user")}/${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
    }
  }
}
