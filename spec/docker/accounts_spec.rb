# encoding: UTF-8
require "docker_helper"

describe "Groups" do
  describe group("lighttpd") do
    it { should exist }
    it { should have_gid 1000 }
  end
end

describe "Accounts" do
  describe user("lighttpd") do
    it { should exist }
    it { should have_uid 1000 }
    it { should belong_to_primary_group "lighttpd" }
  end
end
