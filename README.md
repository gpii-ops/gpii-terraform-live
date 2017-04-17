# gpii-terraform

## Getting Started

### Configure your machine

1. Install [terraform 0.8.8](https://releases.hashicorp.com/terraform/0.8.8/). (Terragrunt currently [doesn't support Terraform 0.9.x](https://github.com/gruntwork-io/terragrunt/issues/158).)
1. Install [terragrunt](https://github.com/gruntwork-io/terragrunt#install).
1. Get an AWS access key and secret key, as described [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html).
1. Configure AWS credentials:
   * _Recommended:_ Install the [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) and run `aws configure` per [the docs](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration). Fill in the access key and secret key you downloaded from Amazon. Leave the other prompts empty.
   * _Or:_ Manually configure `~/.aws` to look like the examples [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles).

### Provision an environment

1. Clone this repo and `cd` into the `dev/` directory.
1. `terragrunt apply-all`
   * The first time this is run in a given account, terragrunt will prompt you to confirm the creation of a DynamoDB entry (for terragrunt locking) and an S3 bucket (for terraform remote state). You must also "opt-in" to use of the Amazon Marketplace CentOS 7 image (the API returns an error with a link to a page where you click buttons).
   * For now we have a single shared dev environment for everyone.
   * Feel free to experiment and make changes, but please leave the environment in the configured state, i.e. so that `terragrunt apply-all` returns no changes.

### Configure an environment

1. Install [terraform-inventory](https://github.com/adammck/terraform-inventory).
1. Clone https://github.com/inclusive-design/ops and `cd` into the `ansible/` directory.
   * If https://github.com/inclusive-design/ops/pull/74 is still open, you'll need to clone [my fork](https://github.com/mrtyler/ops) instead.
1. `TF_STATE=/path/to/gpii-terraform/dev/worker/.terraform/terraform.tfstate ANSIBLE_REMOTE_PORT=22 ansible-playbook -i /usr/local/bin/terraform-inventory deploy_containers_gpii_stg.yml --user centos`

### Manual testing

1. Get a copy of `gpii-key.pem` from `~deploy/.ssh` on `i40`.
   * The configuration process could create user accounts (there is already ansible code in the `ops` repo to do this) but for now we'll use a shared key.
1. `ssh-add /path/to/gpii-key.pem`
1. In your clone of this repo, `terraform output-all` and find `public_ip`. (You can also just look in your scrollback.)
1. `ssh centos@<public_ip>`
1. `sudo docker ps` to see that containers are running
1. `curl localhost:38082/preferences/carla`
   * If it returns some JSON, you have a working preferences server.

### Automated testing

_Skip this step for now._ I broke testing when I reorganized the code into modules :/. I'm still thinking about how to bring it back.

1. Install ruby and bundle (for [kitchen](https://github.com/test-kitchen/test-kitchen) and [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform)).
1. Clone this repo and `cd` into the root of it.
1. `bundle install --path vendor/bundle`
1. `bundle exec kitchen test`
