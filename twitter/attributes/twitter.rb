#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: twitter
# Attributes:: default
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

default[:twitter][:author_name] = "Steve Craig"
default[:twitter][:author_email] = "support@smashrun.com"

default[:twitter][:gem] = [
  { :name => 'twitter', :version => '4.5.0' }
  ]



case node[:platform]
  when "windows"
    default[:twitter][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
    default[:twitter][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  case "#{node[:kernel][:os_info][:version]}"
    when "5.2.3790"
      default[:twitter][:databag] = ['tweeter']
      default[:twitter][:user] = ['sm_devtwit']
    when "6.0.6002"
      default[:twitter][:databag] = ['tweeter']
      default[:twitter][:user] = ['sm_devtwit']
    when "6.1.7601"
      default[:twitter][:databag] = "tweeter"
      default[:twitter][:user] = "sm_devtwit"
  end
  when "redhat","centos","fedora","suse","debian","ubuntu","arch"
    default[:twitter][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
    default[:twitter][:tempdir] = Chef::Config[:file_cache_path]
    default[:twitter][:databag] = "tweeter"
    default[:twitter][:user] = "sm_devtwit"
end


# tweet here by default
# default[:twitter][:admin] = ['@smashrunhq', '#smashrun']
default[:twitter][:admin] = ['@cixelsyd']
