#
# Cookbook Name:: helios
# Attributes:: default
#
# Copyright 2012, Smashrun, Inc.
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

default[:helios][:author_name] = "Steve Craig"
default[:helios][:author_email] = "support@smashrun.com"
default[:helios][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
default[:helios][:sslcert] = "#{node[:helios][:tempdir]}\\sslcert"

case node[:platform]
  when "windows"
    default[:helios][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  when "centos","redhat","fedora","ubuntu","debian","arch"
    default[:helios][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
end

# this was taken from the internet and used to import the certificates
default[:helios][:certmgtps1] = "CertMgmtPack.ps1"
default[:helios][:certmgtps1_template] = "#{node[:helios][:certmgtps1]}.erb"

# this is an array of hashes of authority CA providers and the type of cert to import
default[:helios][:ca] = [ { :name => 'AlphaSSL', :type => ["root","intermediate"] }, { :name => 'DigiCert', :type => ["intermediate"] } ]

# this is the remote location of the certificates to import, one per cert authority
default[:helios][:root][:AlphaSSL] = { :url => "http://www.alphassl.com/support/roots", :file => "root.der" }
default[:helios][:intermediate][:AlphaSSL] = { :url => "https://admin.smashrun.com", :file => "AlphaSSL1.der" }

default[:helios][:intermediate][:DigiCert] = { :url => "https://admin.smashrun.com", :file => "DigiCertHighAssuranceCA-3.der" }
