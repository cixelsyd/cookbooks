#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: nephele
# Attributes:: s3lib
#
# Author:: Steve Craig <support@smashrun.com>
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

default[:s3lib][:author_name] = "Steve Craig"
default[:s3lib][:author_email] = "support@smashrun.com"

case node[:platform]
  when "windows"
    default[:s3lib][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
    default[:s3lib][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  when "redhat","centos","fedora","suse","debian","ubuntu","arch"
    default[:s3lib][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
    default[:s3lib][:tempdir] = Chef::Config[:file_cache_path]
end

# the name of your encrypted data bag
default[:s3lib][:databag] = "s3"

# the name of your s3lib application account inside the s3lib encrypted data bag
default[:s3lib][:user] = "cixelsydego"

# Amazon and "local" are the only choices at this time
default[:s3lib][:store] = 'AWS'
