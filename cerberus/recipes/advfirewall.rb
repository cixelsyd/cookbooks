#
# Cookbook Name:: cerberus
# Recipe:: advfirewall
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
# http://technet.microsoft.com/en-us/library/dd734783(v=ws.10)
#
# THIS RECIPE IS REDUNDANT and was only to simplify testing - firewall.rb contains all this
#
# netsh advfirewall firewall add rule name=rsyncd-tcp dir=in action=allow description="rsync file copy (ip rsync 873)" enable=yes remoteip=192.168.1.1/32 localport=873 protocol=tcp
# netsh advfirewall firewall add rule name=rsyncd-udp dir=in action=allow description="rsync file copy (ip rsync 873)" enable=yes remoteip=192.168.1.1/32 localport=873 protocol=udp

log("begin firewall.rb") { level :debug }
log("running firewall.rb") { level :info }

# two empty arrays to which we'll add the firewall_rules' policys and permitted ips as we go.
firewall_rules = []
ip_permit = []
list= []

search(:ip_permit, "*:*") do |ip|
  permit_details = { "id" => ip["id"],
    "comment" => ip["comment"],
    "fqdn" => ip["fqdn"],
    "ipaddress" => ip["ipaddress"],
    "netmask" => ip["netmask"],
    "owner" => ip["owner"]
  }
  permit = ip["ipaddress"] + ip["netmask"]
  list << permit
  ip_permit << permit_details
end

search(:firewall_rules, "*:*") do |rule|
  policy = { "id" => rule["id"],
    "name" => rule["name"],
    "description" => rule["description"],
    "permit" => rule["permit"],
    "protocol" => rule["protocol"]
  }
  firewall_rules << policy
end

facebook = "31.13.24.0/21,31.13.64.0/18,66.220.144.0/20,69.63.176.0/20,69.171.224.0/19,74.119.76.0/22,103.4.96.0/22,173.252.64.0/18,204.15.20.0/22"

["80","443"].each do |port|
  case node[:hostname]
  when /pww/i
    execute "cerberus_http-tcp-#{port}" do
      timeout 5
      command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port} dir=in action=allow description=\"Microsoft IIS webserver (tcp http #{port})\" enable=yes remoteip=* localport=#{port} protocol=tcp)
    end
  when /qww/i
    execute "cerberus_http-tcp-#{port}-smashrun-clients" do
      timeout 5
      command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port} dir=in action=allow description=\"Microsoft IIS webserver (tcp http #{port})\" enable=yes remoteip=#{list.join(',')} localport=#{port} protocol=tcp)
    end
    execute "cerberus_http-tcp-#{port}-facebook-access" do
      timeout 5
      command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port} dir=in action=allow description=\"Microsoft IIS webserver (tcp http #{port})\" enable=yes remoteip=#{facebook} localport=#{port} protocol=tcp)
    end
  end
end

firewall_rules.each do |rule|
  if rule['protocol'] =~ /ip/
    ["tcp","udp"].each do |multi|
#      log("#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=#{rule['name']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{list.join(',')} localport=#{rule['id']} protocol=#{multi}") { level :info }
      execute "cerberus_#{rule['name']}-#{multi}-#{rule['id']}" do
        timeout 5
        command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_#{rule['name']}-#{multi}-#{rule['id']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{list.join(',')} localport=#{rule['id']} protocol=#{multi})
      end
    end
  else
#    log("#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=#{rule['name']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{list.join(',')} localport=#{rule['id']} protocol=#{rule['protocol']}") { level :info }
    execute "cerberus_#{rule['name']}-#{rule['protocol']}-#{rule['id']}" do
      timeout 5
      command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_#{rule['name']}-#{rule['protocol']}-#{rule['id']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{list.join(',')} localport=#{rule['id']} protocol=#{rule['protocol']})
    end
  end
end

log("end firewall.rb") { level :info }
