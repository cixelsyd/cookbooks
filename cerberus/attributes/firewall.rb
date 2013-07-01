#
# Cookbook Name:: cerberus
# Attributes:: firewall
#
# Copyright 2010, Smashrun, Inc.
# Author:: Steven Craig <support@smashrun.com>
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

# for reference, this is an example of the JSON inside my chef-server data bags:

# inside databag firewall_rules:
# {"name":"nrpe","protocol":"tcp","id":"9999","permit":"enabled","description":"nrpe monitoring (tcp 9999)"}
#
# inside databag ip_permit:
# {"netmask":"/32","comment":"user workstation","fqdn":"hostname.domain.com","ipaddress":"192.168.0.1","id":"hostname","owner":"userid"}

# these are standard
default[:firewall][:author_name] = "Steve Craig"
default[:firewall][:author_email] = "support@smashrun.com"

# this cookbook shows up on my linux machines due to overlap with rsync
# wrap these attributes in a case so they don't pushed to linux machines (no need)
case node[:platform]
  when "windows"
  default[:firewall][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  default[:firewall][:basefw] = "netfw.inf"
  default[:firewall][:basefw_template] = "#{node[:firewall][:basefw]}-on.erb"
  default[:firewall][:deploydir] = "#{node[:kernel][:os_info][:windows_directory]}\\inf"
  default[:firewall][:servicestatus] = "start"
  default[:firewall][:basefw] = "netfw.inf"
  default[:firewall][:basefw_template] = "#{node[:firewall][:basefw]}-on.erb"
  default[:firewall][:deploydir] = "#{node[:kernel][:os_info][:windows_directory]}\\inf"
  case "#{node[:kernel][:os_info][:version]}"
  when "5.2.3790"
    default[:firewall][:servicename] = "SharedAccess"
  when /^6\.*/
    default[:firewall][:servicename] = "MpsSvc"
  end
end
