#
# Cookbook Name:: emailer
# Recipe:: default
# Author:: Steven Craig <support@smashrun.com>
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
log("begin emailer") { level :debug }
log("running emailer") { level :info }

case node[:platform]
  when "windows"
  case "#{node[:kernel][:os_info][:version]}"
    when "5.2.3790"
    include_recipe "emailer::gem_install"
    when "6.0.6002"
    include_recipe "emailer::gem_install"
    when "6.1.7601"
    include_recipe "emailer::gem_install"
  end
  when "redhat","centos","fedora","suse","debian","ubuntu","arch"
    include_recipe "emailer::gem_install"
end

log("end emailer") { level :info }
