terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../gpii-terraform//modules/worker"

    extra_arguments "environment" {
      arguments = [
        "-var", "environment=dev",
      ]
      commands = [
        # This set comes from the example in
        # https://github.com/gruntwork-io/terragrunt#passing-extra-command-line-arguments-to-terraform
        "apply",
        "plan",
        "import",
        "push",
        "refresh"
      ]
    }
  }

  dependencies {
    paths = ["../base"]
  }
}
