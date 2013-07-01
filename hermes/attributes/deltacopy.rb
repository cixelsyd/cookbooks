#
# Cookbook Name:: hermes
# Attribute:: deltacopy
#
# Copyright 2010, Smashrun, Inc.
# Author:: Steven Craig <support@smashrun.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# these are standard
default[:deltacopy][:author_name] = "Steve Craig"
default[:deltacopy][:author_email] = "support@smashrun.com"

# some of these attributes are shared withs linux machines
# the bulk of the attributes are not necessary, however
default[:deltacopy][:user] = "rsyncr"
default[:deltacopy][:databag] = "encrypted_notusers"
default[:deltacopy][:servicestatus] = "start"

case node[:platform]
when "windows"
  default[:deltacopy][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  default[:deltacopy][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  default[:deltacopy][:installdir] = "c:\\DeltaCopy"
  default[:deltacopy][:baseconf] = "deltacd.conf"
  default[:deltacopy][:baseconf_template] = "#{node[:deltacopy][:baseconf]}.erb"
  default[:deltacopy][:basesecret] = "deltacd.secret"
  default[:deltacopy][:basesecret_template] = "#{node[:deltacopy][:basesecret]}.erb"
  default[:deltacopy][:passwdfile] = "#{node[:deltacopy][:user]}.passwd"
  default[:deltacopy][:passwdfile_template] = "#{node[:deltacopy][:passwdfile]}.erb"
  default[:deltacopy][:baselog] = "delta.log"
  default[:deltacopy][:service] = "DCServce.exe"
  default[:deltacopy][:servicename] = "DeltaCopyService"
  default[:deltacopy][:displayname] = "DeltaCopy Server"
  default[:deltacopy][:program] = "DeltaS.exe"
  default[:deltacopy][:mirror] = "https://admin.smashrun.com"
  default[:deltacopy][:installer] = "DeltaCopy.msi"

when "centos","redhat","fedora","ubuntu","debian","arch"
  default[:deltacopy][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
end





