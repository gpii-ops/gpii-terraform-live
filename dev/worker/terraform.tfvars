terragrunt = {
  include {
    path = "${find_in_parent_folders()}"
  }

  terraform {
    source = "../../../gpii-terraform//modules/worker"
  }

  dependencies {
    paths = ["../base"]
  }
}

# NOTE: This value MUST match the value that will be calculated by terragrunt's
# path_relative_to_include(). Otherwise, we will discover the remote state from
# the wrong environment.
#
# I wish we could calculate this value from the terragrunt function or from the
# local path on disk but I couldn't figure a way :(.
environment = "dev"
