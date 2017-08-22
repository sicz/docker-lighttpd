require "docker_helper"

### SERVER_CERTIFICATE #########################################################

describe "Server certificate", :test => :server_certs do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### CONFIG ###################################################################

  user = "lighttpd"
  group = "lighttpd"

  # NOTE: Certificate and key are in the same file
  crt = "/etc/ssl/private/server_crt.pem"
  key = "/etc/ssl/private/server_crt.pem"

  subj = ENV["SERVER_CRT_SUBJECT"]  || "CN=#{ENV["CONTAINER_NAME"]}"

  ### CERTIFICATE ##############################################################

  describe x509_certificate(crt) do
    context "file" do
      subject { file(crt) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(640) }
      it { is_expected.to be_owned_by(user) }
      it { is_expected.to be_grouped_into(group) }
    end
    context "certificate" do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
    end
    its(:subject) { is_expected.to eq "/#{subj}" }
    its(:issuer)  { is_expected.to eq "/CN=Docker Simple CA" }
    its(:validity_in_days) { is_expected.to be > 3650 }
    context "subject_alt_names" do
      it { expect(subject.subject_alt_names).to include("DNS:#{ENV["SERVER_CRT_HOST"]}") }
      it { expect(subject.subject_alt_names).to include("DNS:#{ENV["CONTAINER_NAME"]}") }
      it { expect(subject.subject_alt_names).to include("DNS:localhost") }
      it { expect(subject.subject_alt_names).to include("IP Address:127.0.0.1") }
    end
  end

  ### PRIVATE_KEY ##############################################################

  describe x509_private_key(key) do
    context "file" do
      subject { file(key) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(640) }
      it { is_expected.to be_owned_by(user) }
      it { is_expected.to be_grouped_into(group) }
    end
    context "key" do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate(crt) }
    end
  end

  ### FILES ####################################################################

  describe "Simple CA secrets" do
    [
      # [file]
      "/etc/ssl/private/ca_user.name",
      "/etc/ssl/private/ca_user.pwd",
    ].each do |file|
      context file(file) do
        it { is_expected.to be_file }
        it { is_expected.to be_mode(640) }
        # TODO: ca_user.* files are copied to container with strange owner
        # it { is_expected.to be_owned_by(user) }
        # it { is_expected.to be_grouped_into(group) }
      end
    end
  end

  ##############################################################################

end

################################################################################
