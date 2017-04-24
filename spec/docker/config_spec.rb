# encoding: UTF-8
require "docker_helper"

describe "Config" do
  [
    "/etc/lighttpd/lighttpd.conf",
    "/etc/lighttpd/logs.conf",
    "/etc/lighttpd/server.conf",
  ].each do |file|
    describe file(file) do
      it { should be_file }
    end
  end
end
