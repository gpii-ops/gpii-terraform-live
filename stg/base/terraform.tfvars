# NOTE! This file is generated from a template (and then committed).
# Modify the template, not the output!

terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "github.com/gpii-ops/gpii-terraform//modules/base?ref=2aa46042a0e5ff107a323020bc26cce5be82a984"

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
}

environment = "stg"
