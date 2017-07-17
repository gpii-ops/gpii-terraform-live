require 'rake/clean'

task :default => :ci
task :ci => :test

# We need a DNS zone before kops will do anything, so we have to create it in a
# separate terraform run. We use a separate tmpdir so we don't mix up these
# downloaded modules with the main terraform run's downloaded modules.
TMPDIR_PREREQS = File.absolute_path("../rake-tmp-prereq")

directory TMPDIR_PREREQS
CLOBBER << TMPDIR_PREREQS

task :apply_prereqs => TMPDIR_PREREQS do
  sh "cd ../k8s-cluster-dns && TMPDIR=#{TMPDIR_PREREQS} terragrunt apply-all --terragrunt-non-interactive"
end
CLEAN << "#{TMPDIR_PREREQS}/terragrunt"

task :destroy_prereqs do
  unless ENV["RAKE_NO_DESTROY"]
    sh "cd ../k8s-cluster-dns && TMPDIR=#{TMPDIR_PREREQS} terragrunt destroy-all --terragrunt-non-interactive"
  end
end


TMPDIR = File.absolute_path("../rake-tmp")
ENV["TMPDIR"] = TMPDIR

directory TMPDIR
CLOBBER << TMPDIR


RAKEFILES = FileList.new("../../gpii-terraform/modules/**/Rakefile")

task :generate_modules => [TMPDIR, :apply_prereqs] do
  RAKEFILES.each do |rakefile|
    sh "cd #{File.dirname(rakefile)} && rake generate"
  end
end

if ENV["TF_VAR_environment"].nil?
  if ENV["USER"].nil? || ENV["USER"].empty?
    raise "ERROR: Please set $USER (or $TF_VAR_environment, if you're sure you know what you're doing)."
  end
  user = ENV["USER"]
  ENV["TF_VAR_environment"] = "dev-#{user}"
end
if ENV["TF_VAR_cluster_name"].nil?
  ENV["TF_VAR_cluster_name"] = "k8s-#{ENV["TF_VAR_environment"]}.gpii.net"
end

task :wait_for_api do
  # Technically it would be more correct to get this value directly from
  # the Terraform run that created the zone. This is simpler, though.
  zone = `aws route53 list-hosted-zones \
    | jq '.HostedZones[] | select(.Name=="#{ENV["TF_VAR_cluster_name"]}.") | .Id' \
  `
  if zone.empty?
    raise "Could not find route53 zone for cluster #{ENV['TF_VAR_cluster_name']}. Make sure :apply_prereqs has run successfully."
  end
  zone.chomp!
  zone.gsub!(%r{"/hostedzone/(.*)"}, "\\1")

  puts "We must wait for:"
  puts "- the API server to come up and report itself to dns-controller"
  puts "- dns-controller to create api.* A records"
  puts "- A records to propagate so that the local machine can see them"
  puts "(More info: https://github.com/kubernetes/kops/blob/master/docs/boot-sequence.md)"
  puts
  puts "If we look up api.* records too early, local DNS may cache the negative lookup and things will break."
  puts "On my home internet, behind an AirPort, it takes 10 minutes for the bad result to clear and things to work again."
  puts
  puts "It usually takes about 3 minutes for the cluster to converge and DNS records to appear."
  puts
  puts "Waiting for API to have DNS..."
  puts "(Note that this will wait potentially forever for DNS records to appear.)"
  puts "(You can Ctrl-C out of this safely. You may need to run :destroy afterward.)"

  api_hostname = "api.#{ENV['TF_VAR_cluster_name']}"
  sleep_secs = 20
  dns_ready = false
  until dns_ready
    # Technically it would be more correct to get the name of the API record
    # directly from the Terraform run that created the cluster (there is a
    # dedicated output for this, consumed by kitchen-terraform). This is
    # simpler, though.
    ### --max-items 1 \
    ### --query \"ResourceRecordSets[?Name == '#{api_hostname}.']\" \
    sh "aws route53 list-resource-record-sets \
      --hosted-zone-id '#{zone.chomp}' \
      | grep -q '#{api_hostname}' \
    " do |ok, res|
      if ok
        puts "...ready!"
        dns_ready = true
      else
        puts "...not ready yet. Sleeping #{sleep_secs}s..."
        sleep sleep_secs
      end
    end
  end
end

task :test => :generate_modules do
  sh "bundle exec kitchen create -l debug"
  begin
    sh "bundle exec kitchen converge -l debug"
    Rake::Task["wait_for_api"].invoke
    sh "bundle exec kitchen verify -l debug"
  ensure
    Rake::Task["destroy"].invoke
  end
end
CLEAN << "#{TMPDIR}/terragrunt"

task :destroy do
  unless ENV["RAKE_NO_DESTROY"]
    sh "bundle exec kitchen destroy -l debug"
    Rake::Task["destroy_prereqs"].invoke
  end
end

task :clean_modules do
  RAKEFILES.each do |rakefile|
    sh "cd #{File.dirname(rakefile)} && rake clean"
  end
end
Rake::Task["clean"].enhance do
    Rake::Task["clean_modules"].invoke
end

task :clobber_modules do
  RAKEFILES.each do |rakefile|
    sh "cd #{File.dirname(rakefile)} && rake clobber"
  end
end
Rake::Task["clobber"].enhance do
    Rake::Task["clobber_modules"].invoke
end



# vim: ts=2 sw=2:
