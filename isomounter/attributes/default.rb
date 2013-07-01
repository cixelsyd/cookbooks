#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: ismounter
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

# these are standard
default[:isomounter][:author_name] = "Steve Craig"
default[:isomounter][:author_email] = "support@smashrun.com"
default[:isomounter][:version] = '0.7.0'
default[:isomounter][:gem] = "win32-registry"

case node[:platform]
  when "windows"
    default[:isomounter][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  when "centos","redhat","fedora","ubuntu","debian","arch"
    default[:isomounter][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
end

# the dirs
default[:isomounter][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)

# the version
default[:isomounter][:binary] = "MagicDisc.exe"
default[:isomounter][:version] = "2.7.106"

default[:isomounter][:shortcuts] = ['c:\Documents and Settings\All Users\Start Menu\Programs\Startup',
                                'c:\Documents and Settings\All Users\Desktop']
default[:isomounter][:shortcut_name] = "MagicDisc" #name of the .lnk

if node[:kernel][:machine] == "x86_64"
  default[:isomounter][:installdir] = "C:\\Program Files (x86)\\MagicDisc"
  default[:isomounter][:installer] = "setup_magicdisc.exe"
  default[:isomounter][:url] = "http://www.magiciso.com/#{node[:isomounter][:installer]}"
  default[:isomounter][:misoexe] = "miso.exe"
  default[:isomounter][:misourl] = "http://www.magiciso.com/bin/#{node[:isomounter][:misoexe]}"
else
  if node[:kernel][:machine] == "i386"
    default[:isomounter][:installdir] = "C:\\Program Files\\MagicDisc"
    default[:isomounter][:installer] = "setup_magicdisc.exe"
    default[:isomounter][:url] = "http://www.magiciso.com/#{node[:isomounter][:installer]}"
    default[:isomounter][:misoexe] = "miso.exe"
    default[:isomounter][:misourl] = "http://www.magiciso.com/bin/#{node[:isomounter][:misoexe]}"
  end
end