# encoding: UTF-8
require "docker_helper"

describe "Web server" do

  context "configuration file" do
    [
      "/etc/lighttpd/lighttpd.conf",
      "/etc/lighttpd/logs.conf",
      "/etc/lighttpd/server.conf",
      "/etc/ssl/openssl.cnf",
    ].each do |file|
      context file do
        it "exists" do
          expect(file(file)).to exist
          expect(file(file)).to be_readable.by_user("lighttpd")
        end
      end
    end
  end

  context "user 'lighttpd'" do
    it "has uid 1000" do
      expect(user("lighttpd")).to exist
      expect(user("lighttpd")).to have_uid(1000)
    end
    it "belongs to primary group 'lighttpd'" do
      expect(user("lighttpd")).to belong_to_primary_group("lighttpd")
    end
  end

  context "group 'lighttpd'" do
    it "has gid 1000" do
      expect(group("lighttpd")).to exist
      expect(group("lighttpd")).to have_gid(1000)
    end
  end

  context "daemon" do
    it "is listening on TCP port 80" do
      expect(process("lighttpd")).to be_running
      expect(port(80)).to be_listening.with("tcp")
      expect(port(443)).not_to be_listening.with("tcp")
    end
    context "returns" do
      subject do
        command("curl -s http://localhost")
      end
      it  "default index.html" do
        expect(subject.exit_status).to eq(0)
        expect(subject.stdout).to eq("InDeX\n")
      end
    end
  end
end
