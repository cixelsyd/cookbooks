#
# Cookbook Name:: trac4r
# Recipe:: example
# Author:: Steven Craig <support@smashrun.com>
#
# Copyright 2010, Smashrun, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# example ticket attach restoredb report

ruby_block "#{node[:hostname]} update ticket 9999 with tag foo restoredb report" do
  only_if { File.exists?("example.log") }
  block {
      begin
        require "xmlrpc/base64"
      rescue LoadError
      end
      fn = "example.log"
      fh = File.new(fn, "rb")
      sdata = fh.read
      data = XMLRPC::Base64.new(sdata)
      begin
        secret = Chef::EncryptedDataBagItem.load_secret("#{node[:trac4r][:databag_secret]}")
        user = Chef::EncryptedDataBagItem.load("#{node[:trac4r][:databag]}", "#{node[:trac4r][:user]}", secret)
      rescue
      end
      Tracker.ticketattach("#{node[:trac4r][:url]}", user["id"], user["password"], "9999", "example.log", "#{node[:hostname]} update ticket 9999 with tag foo restoredb report", data)
  }
  ignore_failure true 
end
