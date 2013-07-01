#
# Cookbook Name:: reginjector
# Recipe:: default
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

case "#{node[:kernel][:os_info][:version]}"
  when "5.2.3790" # windows 2003 i386
  include_recipe "reginjector::injection"
  when "6.0.6002" # windows 2008 i386
  include_recipe "reginjector::v2-injection"
  include_recipe "reginjector::chefenv"
  when "6.1.7601" # windows 2008 x86_64 R2 datacenter edition
  include_recipe "reginjector::v2-injection"
  include_recipe "reginjector::chefenv"
end
