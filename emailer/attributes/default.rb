#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: emailer
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

default[:emailer][:author_name] = "Steve Craig"
default[:emailer][:author_email] = "support@smashrun.com"

default[:emailer][:gem] = [
  { :name => 'mail', :version => '2.3.0' }
  ]

case node[:platform]
  when "windows"
    default[:emailer][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  when "centos","redhat","fedora","ubuntu","debian","arch"
    default[:emailer][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
end

# to is an array so that multiple addresses can be specified
default[:emailer][:to] = ['admin@smashrun.com']

default[:emailer][:from] = "smtracuser@gmail.com"

default[:emailer][:user] = "smtracuser"
default[:emailer][:databag] = "encrypted_notusers"
