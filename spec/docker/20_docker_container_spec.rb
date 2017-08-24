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
      ca_crt_file="/etc/ssl/certs/simple-ca.crt"
      system("curl -fksS -o #{ca_crt_file} https://simple-ca.local/ca.crt")
      system("update-ca-certificates > /dev/null 2>&1")
      system("cat #{ca_crt_file} >> /etc/ssl/certs/ca-certificates.crt")
    end
    # Execute Serverspec command locally
    before(:each)  { set :backend, :exec }
    [
      # [url, stdout, stderr]
      [ "http://lighttpd.local",
        "^#{IO.binread("spec/fixtures/www/index.html")}$",
        "\\r\\n< HTTP/1.1 301 Moved Permanently\\r\\n< Location: https://lighttpd.local/\\r\\n",
      ],
      [ "http://lighttpd.local/index.html",
        "^#{IO.binread("spec/fixtures/www/index.html")}$",
        "\\r\\n< HTTP/1.1 301 Moved Permanently\\r\\n< Location: https://lighttpd.local/index.html\\r\\n",
      ],
      [ "https://lighttpd.local",
        "^#{IO.binread("spec/fixtures/www/index.html")}$",
      ],
      [ "https://lighttpd.local/index.html",
        "^#{IO.binread("spec/fixtures/www/index.html")}$",
      ],
    ].each do |url, stdout, stderr|
      context url do
        subject { command("curl --location --silent --show-error --verbose #{url}") }
        it "should exist" do
          expect(subject.exit_status).to eq(0)
        end
        it "should match \"#{stdout.gsub(/\n/, "\\n")}\"" do
          expect(subject.stdout).to match(stdout)
        end unless stdout.nil?
        it "should match \"#{stderr}\"" do
          expect(subject.stderr).to match(stderr)
        end unless stderr.nil?
      end
    end
  end

  ##############################################################################

end
