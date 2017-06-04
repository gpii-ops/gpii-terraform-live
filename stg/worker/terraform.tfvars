# NOTE! This file is generated from a template (and then committed).
# Modify the template, not the output!

terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "github.com/gpii-ops/gpii-terraform//modules/worker?ref=2f959141f47617d14124e0e84d52e06a8b5d5c77"

    # Force Terraform to keep trying to acquire a lock for up to 20 minutes if someone else already has the lock
    extra_arguments "retry_lock" {
      arguments = [
        "-lock-timeout=20m"
      ]
      commands = [
        "init",
        "apply",
        "refresh",
        "import",
        "plan",
        "taint",
        "untaint",
        "destroy"
      ]
    }
  }

  dependencies {
    paths = ["../base"]
  }
}

bucket = "gpii-terraform-state"
# NOTE: This value MUST match the value that will be calculated by terragrunt's
# path_relative_to_include(). Otherwise, we will discover the remote state from
# the wrong environment.
#
# I wish we could calculate this value from the terragrunt function or from the
# local path on disk but I couldn't figure a way :(.
environment = "stg"
