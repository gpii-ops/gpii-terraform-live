# NOTE! This file is generated from a template (and then committed).
# Modify the template, not the output!

terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "github.com/gpii-ops/gpii-terraform//modules/worker?ref=8ff1e94e1e461795db18eeab04fbc805f7ef1398"

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
