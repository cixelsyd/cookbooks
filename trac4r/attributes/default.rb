#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: trac4r
# Attributes:: default
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

default[:trac4r][:author_name] = "Steve Craig"
default[:trac4r][:author_email] = "support@smashrun.com"

default[:trac4r][:gem] = [
  { :name => 'json', :version => '1.7.3' },
  { :name => 'trac4r', :version => '1.2.4' }
  ]

default[:trac4r][:url] = "https://admin.smashrun.com/trac"
default[:trac4r][:pnpbaseurl] = "https://doh.ikickass.com/pnp4nagios"

default[:trac4r][:hostwiki] = "wikicreate"
default[:trac4r][:hostwiki_template] = "#{node[:trac4r][:hostwiki]}.erb"
default[:trac4r][:readmewiki] = "wikireadme"
default[:trac4r][:readmewiki_template] = "#{node[:trac4r][:readmewiki]}.erb"

case node[:platform]
  when "windows"
    default[:trac4r][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
    default[:trac4r][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
    default[:trac4r][:wikidir] = "#{node[:trac4r][:tempdir]}\\tracwiki"
  case "#{node[:kernel][:os_info][:version]}"
    when "5.2.3790"
      default[:trac4r][:databag] = "encrypted_notusers"
      default[:trac4r][:user] = "continuity"
    when "6.0.6002"
      default[:trac4r][:databag] = "encrypted_notusers"
      default[:trac4r][:user] = "continuity"
    when "6.1.7601"
      default[:trac4r][:databag] = "encrypted_notusers"
      default[:trac4r][:user] = "continuity"
  end
  when "redhat","centos","fedora","suse","debian","ubuntu","arch"
    default[:trac4r][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
    default[:trac4r][:tempdir] = Chef::Config[:file_cache_path]
    default[:trac4r][:wikidir] = "#{node[:trac4r][:tempdir]}/tracwiki"
    default[:trac4r][:databag] = "encrypted_notusers"
    default[:trac4r][:user] = "continuity"
end
