terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../gpii-terraform//modules/worker"

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
        "untaint"
      ]
    }

    # We jump through the hoop of passing `environment` via the command line
    # (automatically via `extra_arguments`) so that we can use terragrunt's
    # get_env() helper.
    extra_arguments "environment" {
      arguments = [
        "-var", "environment=dev-${get_env("USER", "unknown-user")}",
      ]
      commands = [
        # This set comes from the example in
        # https://github.com/gruntwork-io/terragrunt#passing-extra-command-line-arguments-to-terraform
        "apply",
        "plan",
        "import",
        "push",
        "refresh",
        # I added these when I ran into errors
        "destroy"
      ]
    }
  }

  dependencies {
    paths = ["../base"]
  }
}
