# encoding: UTF-8
require "docker_helper"

describe "Services" do
  describe process("lighttpd") do
    it { should be_running }
  end
  describe port(80) do
    it { should be_listening.with('tcp') }
  end
  describe command("curl -s http://localhost") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should eq "InDeX\n" }
  end
end
