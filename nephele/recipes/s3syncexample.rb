#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: nephele
# Recipe:: s3syncexample
#
# Copyright 2012, Smashrun, Inc.
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

log("begin s3syncexample.rb") { level :debug }
log("running s3syncexample.rb") { level :info }

begin
  secret = Chef::EncryptedDataBagItem.load_secret("#{node[:s3lib][:databag_secret]}")
  settings = Chef::EncryptedDataBagItem.load("#{node[:s3lib][:databag]}", "#{node[:s3lib][:user]}", secret)
rescue
end

case node['platform_family']
when "rhel","fedora"
  include_recipe "nephele::install_gem"

when "windows"
  case "#{node[:kernel][:os_info][:version]}"
  when "5.2.3790"
    log("Nephele the weather dominator only works on Windows 2008 currently.") { level :info }
    log("Seriously, if you are running Windows 2003 inside AWS you should tackle that issue first.") { level :info }
  when /^6\.*/
    include_recipe "nephele::install_gem"

    ruby_block "s3sync_example" do
      block {
        Dir.chdir("D:\\images\\")
        # this will sync the files inside all directories immediately under "images"
        list = Dir['*/']
        list.each { |d|
          S3lib.sync("#{node[:s3lib][:store]}", d, "#{node[:fqdn].downcase}", settings["aws_access_key_id"], settings["aws_secret_access_key"],true) }
      }
      action :nothing
    end

    ruby_block "s3sync_example" do
      block {
        ["D:\\wwwRoot\\Smashrun\\images\\team"].each { |d|
          S3lib.sync("#{node[:s3lib][:store]}", d, "pww.sm", settings["aws_access_key_id"], settings["aws_secret_access_key"],true) }
      }
    end

  end
end

log("end s3syncexample.rb") { level :debug }
