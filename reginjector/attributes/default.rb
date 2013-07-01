#
# Cookbook Name:: reginjector
# Attributes:: default.rb
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


# these are standard
default[:reginjector][:author_name] = "Steve Craig"
default[:reginjector][:author_email] = "support@smashrun.com"

case node[:platform]
when "windows"
  default[:reginjector][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  default[:reginjector][:regeditor_version] = "Windows Registry Editor Version 5.00"

  # the dirs
  default[:reginjector][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  default[:reginjector][:workingdir] = "#{node[:reginjector][:tempdir]}\\regfragments"

  # the registry deployment
  # standard registry deployment batch file
  default[:reginjector][:regdeploybat] = "reg_deploy.bat"
  default[:reginjector][:regdeploybat_template] = "#{node[:reginjector][:regdeploybat]}.erb"

  if node[:hostname] =~ /^.ww.+$/
    default[:reginjector][:payload] = ["iis6_urlhack","fingerprints","disable_uac","au_settings","KB2656351","dw20","reg_disableipv6","tokenfilter"]
  else
    default[:reginjector][:payload] = ["fingerprints","disable_uac","au_settings","KB2656351","dw20","reg_disableipv6","tokenfilter"]
  end

when "centos","redhat","fedora","ubuntu","debian","arch"
  default[:reginjector][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
end
