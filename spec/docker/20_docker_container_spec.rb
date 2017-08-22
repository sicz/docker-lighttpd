require "docker_helper"

### DOCKER_CONTAINER ###########################################################

describe "Docker container", :test => :docker_container do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_CONTAINER #########################################################

  describe docker_container(ENV["CONTAINER_NAME"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to be_running }
  end

  ### PROCESSES ################################################################
  describe "Processes" do
    [
      # [process,                   user,             group,            pid]
      ["/sbin/tini",                "root",           "root",           1],
      ["/usr/sbin/lighttpd",        "lighttpd",       "lighttpd"],
    ].each do |process, user, group, pid|
      context process(process) do
        it { is_expected.to be_running }
        its(:pid) { is_expected.to eq(pid) } unless pid.nil?
        its(:user) { is_expected.to eq(user) } unless user.nil?
        its(:group) { is_expected.to eq(group) } unless group.nil?
      end
    end
  end

  ### PORTS ####################################################################

  describe "Ports" do
    [
      # [port, proto]
      [80,  "tcp"],
      [443, "tcp"],
    ].each do |port, proto|
      context port(port) do
        it { is_expected.to be_listening.with(proto) }
      end
    end
  end

  ### URLS #####################################################################

  describe "URLs" do
    # Download Simple CA certificate
    before(:context) do
      ca_crt_file="/etc/ssl/certs/ca_crt.pem"
      system("curl -ksS -o #{ca_crt_file} https://simple-ca.local/ca.pem")
      system("update-ca-certificates > /dev/null 2>&1")
      system("cat #{ca_crt_file} >> /etc/ssl/certs/ca-certificates.crt")
    end
    # Execute Serverspec command locally
    before(:each)  { set :backend, :exec }
    [
      # [url,                   curl_opts,          exit_status, stdout]
      ["http://lighttpd.local", "--location",       0,  IO.binread("spec/fixtures/www/index.html")],
      ["https://lighttpd.local/index.html",  nil,   0,  IO.binread("spec/fixtures/www/index.html")],
    ].each do |url, curl_opts, exit_status, stdout|
      context url do
        subject { command("curl #{curl_opts} --silent --show-error #{url}") }
        it "should exist" do
          expect(subject.exit_status).to eq(exit_status)
        end
        it "should return #{stdout.strip}" do
          expect(subject.stdout).to eq(stdout)
        end unless stdout.nil?
      end
    end
  end

  ##############################################################################

end
