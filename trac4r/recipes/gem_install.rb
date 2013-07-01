#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: trac4r
# Recipe:: trac4r
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

log("begin trac4r.rb") { level :debug }
log("running trac4r.rb") { level :info }

["#{node[:trac4r][:tempdir]}", "#{node[:trac4r][:wikidir]}"].each do |dir|
  directory "#{dir}" do
    action :create
    not_if { File.exists?("#{dir}") }
    recursive true
  end
end

node[:trac4r][:gem].each do |g|
  r = gem_package("#{g[:name]}") do
    action :nothing
    version "#{g[:version]}"
  end
  r.run_action(:install)
  Gem.clear_paths
end

if node[:chef_packages][:chef][:version] >= "0.10.9"
  node[:trac4r][:gem].each do |g|
    chef_gem("#{g[:name]}") do
      action :install
      version "#{g[:version]}"
    end
  end
end

log("end trac4r.rb") { level :info }
