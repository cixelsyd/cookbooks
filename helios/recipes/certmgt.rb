#
# Cookbook Name:: helios
# Recipe:: certmgt
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

log("create directories if necessary") { level :debug }
["#{node[:helios][:tempdir]}", "#{node[:helios][:sslcert]}"].each do |dir|
  directory "#{dir}" do
    action :create
    not_if { File.exists?("#{dir}") }
    recursive true
  end
end

templated = nil
begin
  templated = resources(:template => "#{node[:helios][:certmgtps1_template]}")
    rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:helios][:tempdir]}\\#{node[:helios][:certmgtps1]}" do
    source "#{node[:helios][:certmgtps1_template]}"
    backup false
    variables({
      :author_name => "#{node[:helios][:author_name]}",
      :author_email => "#{node[:helios][:author_email]}",
      :certmgtps1 => "#{node[:helios][:certmgtps1]}",
      :certmgtps1_template => "#{node[:helios][:certmgtps1_template]}",
      :baselog => "#{node[:helios][:baselog]}",
      :system_dir => "#{node[:kernel][:os_info][:system_directory]}"
    })
  end
end


node[:helios][:ca].each do |ca|
  ca[:type].each do |t|
    log("download #{t} #{ca[:name]} from web if necessary") { level :debug }
    file = node[:helios]["#{t}"]["#{ca[:name]}"][:file]
    url = node[:helios]["#{t}"]["#{ca[:name]}"][:url]
    remote_file "#{t}-#{ca[:name]}-#{file}" do
      action :create
      not_if { File.exists?("#{node[:helios][:sslcert]}\\#{t}-#{ca[:name]}-#{file}") }
      backup 5
      source "#{url}/#{file}"
      path "#{node[:helios][:sslcert]}\\#{t}-#{ca[:name]}-#{file}"
    end

    case "#{t}"
    when /root/
      container = "AuthRoot"
    when /intermediate/
      container = "CA"
    when /personal/
      container = "My"
    when /addressbook/
      container = "AddressBook"
    when /untrusted/
      container = "Disallowed"
    when /enterprise/
      container = "Trust"
    when /person/
      container = "TrustedPeople"
    when /publisher/
      container = "TrustedPublisher"
    end

    execute "#{t}-#{ca[:name]}-#{file}" do
      cwd "#{node[:helios][:sslcert]}"
      timeout 30
      command %Q(#{ENV['WINDIR']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -command "& { . #{node[:helios][:tempdir]}\\#{node[:helios][:certmgtps1]}; Import-Certificate -Path #{node[:helios][:sslcert]}\\#{t}-#{ca[:name]}-#{file} -Storage LocalMachine -Container #{container} } ")
      ignore_failure true
    end

  end
end

