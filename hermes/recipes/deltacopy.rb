#
# Cookbook Name:: hermes
# Recipe:: deltacopy
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
# WITHOUT WARRretrievedbIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# for installing as a service, see "sc" command kb link below
# http://support.microsoft.com/kb/251192
#
# deltacopy is slightly crazy - seems that, once installed by Chef on Windows 2003, it specifically needs to have the deltas.exe run once before it will work properly
# or (2008) run the msi manually, should pickup the correct settings if chef has already placed it on the server

log("begin deltacopy.rb") { level :debug }
log("running deltacopy.rb") { level :info }

# ensure necessary dirs are setup and available
["#{node[:deltacopy][:tempdir]}", "#{node[:deltacopy][:installdir]}"].each do |dir|
  # log("create #{dir} directory if necessary") { level :debug }
  directory "#{dir}" do
    action :create
    not_if { File.exists?("#{dir}") }
    recursive true
  end
end

begin
  secret = Chef::EncryptedDataBagItem.load_secret("#{node[:deltacopy][:databag_secret]}")
  user = Chef::EncryptedDataBagItem.load("#{node[:deltacopy][:databag]}", "#{node[:deltacopy][:user]}", secret)
rescue
end

dst = "#{node[:deltacopy][:tempdir]}\\#{node[:deltacopy][:installer]}"

# download the installer
remote_file dst do
  source "#{node[:deltacopy][:mirror]}/#{node[:deltacopy][:installer]}"
  not_if { File.exists?(dst) }
end


case "#{node[:kernel][:os_info][:version]}"
  when "5.2.3790" # windows 2003 i386
    installcmd = "msiexec /quiet /passive /lvx #{node[:deltacopy][:installdir]}\\delta_install.log /qn /norestart /i #{node[:deltacopy][:tempdir]}\\#{node[:deltacopy][:installer]} INSTALLDIR=\"#{node[:deltacopy][:installdir]}\""

  when "6.0.6002" # windows 2008 i386
    installcmd = "msiexec /quiet /passive /lvx #{node[:deltacopy][:installdir]}\\delta_install.log /qn /norestart /i #{node[:deltacopy][:tempdir]}\\#{node[:deltacopy][:installer]} INSTALLDIR=\"#{node[:deltacopy][:installdir]}\""

  when "6.1.7601" # windows 2008 x86_64 R2 datacenter edition
    installcmd = "#{node[:kernel][:os_info][:windows_directory]}\\sysWOW64\\msiexec.exe /quiet /passive /lvx #{node[:deltacopy][:installdir]}\\delta_install.log /qn /norestart /i #{node[:deltacopy][:tempdir]}\\#{node[:deltacopy][:installer]} INSTALLDIR=\"#{node[:deltacopy][:installdir]}\""
end

# run the installer
execute "install #{node[:deltacopy][:service]}" do
  cwd "#{node[:deltacopy][:tempdir]}"
  command %Q(#{installcmd})
  timeout 30
  not_if { File.exists?("#{node[:deltacopy][:installdir]}/#{node[:deltacopy][:service]}") }
end

# register the service
execute "install_#{node[:deltacopy][:servicename]}" do
  cwd "#{node[:deltacopy][:installdir]}"
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}"}).nil? }
  timeout 30
  command %Q(#{node[:kernel][:os_info][:system_directory]}\\sc.exe create #{node[:deltacopy][:servicename]} binPath= "#{node[:deltacopy][:installdir]}\\#{node[:deltacopy][:service]}" start= auto DisplayName= "#{node[:deltacopy][:displayname]}")
  notifies :enable, "service[#{node[:deltacopy][:servicename]}]", :immediately
  notifies :start, "service[#{node[:deltacopy][:servicename]}]", :delayed
end

# happy service time
log("service #{node[:deltacopy][:servicename]} registration if necessary") { level :debug }
service "#{node[:deltacopy][:servicename]}" do
  action :nothing
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end

ip_permit = []

# grab the firewall rules - this would be great if it could be merged with firewall.rb inside cerberus
# to prevent duplicate calls
search(:ip_permit, "*:*") do |ip|
  permit = { "id" => ip["id"],
    "comment" => ip["comment"],
    "fqdn" => ip["fqdn"],
    "ipaddress" => ip["ipaddress"],
    "netmask" => ip["netmask"],
    "owner" => ip["owner"]
  }
  ip_permit << permit
end

# need a template for the server virtual directory settings
log("process #{node[:deltacopy][:baseconf_template]} if necessary") { level :debug }
templated = nil
begin
  templated = resources(:template => "#{node[:deltacopy][:baseconf_template]}")
    rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:deltacopy][:installdir]}\\#{node[:deltacopy][:baseconf]}" do
    source "#{node[:deltacopy][:baseconf_template]}"
    variables({
              :ip_permit => ip_permit,
              :author_name => "#{node[:deltacopy][:author_name]}",
              :author_email => "#{node[:deltacopy][:author_email]}",
              :baseconf => "#{node[:deltacopy][:baseconf]}",
              :baseconf_template => "#{node[:deltacopy][:baseconf_template]}",
              :basesecret => "#{node[:deltacopy][:basesecret]}",
              :basesecret_template => "#{node[:deltacopy][:basesecret_template]}",
              :deltauser => user["id"],
              :deltapasswd => user["password"],
              :installdir => "#{node[:deltacopy][:installdir]}",
              :hostname => "#{node[:hostname]}"
    })
    backup false
    notifies :restart, "service[#{node[:deltacopy][:servicename]}]", :immediately
  end
end

# need a template for the rsync user secrets
log("process #{node[:deltacopy][:basesecret_template]} if necessary") { level :debug }
templated = nil
begin
  templated = resources(:template => "#{node[:deltacopy][:basesecret_template]}")
    rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:deltacopy][:installdir]}\\#{node[:deltacopy][:basesecret]}" do
    source "#{node[:deltacopy][:basesecret_template]}"
    variables({
              :author_name => "#{node[:deltacopy][:author_name]}",
              :author_email => "#{node[:deltacopy][:author_email]}",
              :baseconf => "#{node[:deltacopy][:baseconf]}",
              :baseconf_template => "#{node[:deltacopy][:baseconf_template]}",
              :basesecret => "#{node[:deltacopy][:basesecret]}",
              :basesecret_template => "#{node[:deltacopy][:basesecret_template]}",
              :deltauser => user["id"],
              :deltapasswd => user["password"],
              :installdir => "#{node[:deltacopy][:installdir]}",
              :hostname => "#{node[:hostname]}"
    })
    backup false
    notifies :restart, "service[#{node[:deltacopy][:servicename]}]", :immediately
  end
end

# need a template for the rsync user passwd
log("process #{node[:deltacopy][:passwdfile_template]} if necessary") { level :debug }
templated = nil
begin
  templated = resources(:template => "#{node[:deltacopy][:passwdfile_template]}")
    rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:deltacopy][:installdir]}\\#{node[:deltacopy][:passwdfile]}" do
    source "#{node[:deltacopy][:passwdfile_template]}"
    variables({
              :deltapasswd => user["password"]
    })
    backup false
    notifies :restart, "service[#{node[:deltacopy][:servicename]}]", :immediately
  end
end

log("end deltacopy.rb") { level :debug }