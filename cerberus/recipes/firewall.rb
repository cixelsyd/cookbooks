#
# Cookbook Name:: cerberus
# Recipe:: firewall
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
# http://technet.microsoft.com/en-us/library/cc737845(WS.10).aspx
# http://technet.microsoft.com/en-us/library/bb490621.aspx
# http://www.microsoft.com/download/en/confirmation.aspx?id=18996
#
# currently these only work correctly with one adapter - have not researched why

log("begin firewall.rb") { level :debug }
log("running firewall.rb") { level :info }

# arrays to which we'll add the firewall_rules' policys and permitted ips
firewall_rules = []
ip_permit = []
list = []

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


case "#{node[:kernel][:os_info][:version]}"
  when "5.2.3790"

    log("enable #{node[:firewall][:servicename]} logging if instructed") { level :debug }
    execute "netsh_logging" do
      cwd "#{node[:kernel][:os_info][:system_directory]}"
      command "#{node[:kernel][:os_info][:system_directory]}\\netsh firewall set logging droppedpackets = enable connections = enable"
      ignore_failure true 
      timeout 30
      action :nothing
    end

    log("reload #{node[:firewall][:servicename]} rules if instructed by template change") { level :debug }
    execute "netsh_reload" do
      cwd "#{node[:kernel][:os_info][:system_directory]}"
      command "#{node[:kernel][:os_info][:system_directory]}\\netsh firewall reset"
      returns [0,4]
      timeout 30
      action :nothing
      notifies :run, "execute[netsh_logging]"
    end

    templated = nil
    begin
      templated = resources(:template => "#{node[:firewall][:basefw_template]}")
        rescue Chef::Exceptions::ResourceNotFound
      templated = template "#{node[:firewall][:deploydir]}\\#{node[:firewall][:basefw]}" do
        source "#{node[:firewall][:basefw_template]}"
        backup 10
        variables({
          :ip_permit => ip_permit,
          :firewall_rules => firewall_rules,
          :hostname => "#{node[:hostname]}",
          :author_name => "#{node[:firewall][:author_name]}",
          :author_email => "#{node[:firewall][:author_email]}",
          :basefw => "#{node[:firewall][:basefw]}",
          :basefw_template => "#{node[:firewall][:basefw_template]}"
          })
        notifies :run, "execute[netsh_reload]"
      end
    end

  when /^6\.*/

    log("Begin registry search for stale firewall rules") {level :info}
    # http://en.wikibooks.org/wiki/Ruby_Programming/Standard_Library/Win32::Registry
    # firewall rules are stored inside two places inside the registry: CurrentControlSet and ControlSet001
    # grab all keys that start with a brace (system rules dont have braced, GUID key-names) from:
    # HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules
    # slurp and then discard first item (version of rule); then split contents by pipe / equals
    # check Name= for "cerberus_" and push onto array for deletion
    # ensure we use the netsh delete command because that purges the rules from memory
    # simply deleting the objects in the registry works, but leaves firewall objects in RAM
    # these objects are not purged until reboot, and dramatically increase the time the netsh command takes to run
    # this seems to be more of an issue with Win2008 i386 than with Win2008R2

    begin
      require 'win32/registry'
    rescue LoadError
    end

    regbase = "SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\FirewallRules"
    raccess = Win32::Registry::KEY_READ
    waccess = Win32::Registry::KEY_ALL_ACCESS
    rule_array = []
    rule_hash = {}
    Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}", raccess) do |reg|
      reg.each do |name,type,data|
        if name =~ /^\{.*/
          #log("found rule name #{name} contains #{data}") {level :debug}
          data.split('|').each do |x|
            k,v = x.split('=')
            if "#{v}" =~ /^cerberus_/
              #log("#{name} is GUID for cerberus fw rule #{v}") {level :debug}
              rule_hash["#{name}"] = "#{v}"
            end
          end
        end
      end
      rule_hash.each do |key,value|
        log("registry GUID #{key} maps to firewall name #{value}") {level :info}
      end
    end

    # kronos, my Windows Scheduled Task Manager, had strange issues deleting keys
    # sorting and then deleting stuff "from the bottom up" seemed to fix that
    # so we do it here as well
    # this is now not necessary as we use the "netsh advfirewall firewall delete" command
    # instead of direct registry edit
    # but left the sort in for the heck of it
    log("Begin registry values sort by id") {level :info}
    rule_array = rule_hash.sort { |x,y| y[0] <=> x[0] }
    log("End registry values sort by id") {level :info}
    log("Begin firewall rule cleanse by GUID") {level :info}

    rule_array.each do |k,v|
      execute "cerberus_#{v}-#{k}" do
        timeout 6
        # this is a HUGE timeout! y u take so long!?
        command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall delete rule name=#{v})
      end
    end

    log("End firewall rule cleanse by GUID") {level :info}
    log("End registry search for stale firewall rules") {level :info}
    log("Begin import current firewall rules") {level :info}

    # first, simply enable ICMP ping
    # want all machines to be pingable
    # this is a quick hack because
    # unsure if cereberus supports icmp protocol inside databags
    # do not believe it does
    ip_permit.each do |ip|
      execute "cerberus_ICMP-echo-request-#{ip['ipaddress']}#{ip['netmask']}" do
        timeout 5
        command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_ICMP-echo-request-#{ip['ipaddress']}#{ip['netmask']} dir=in action=allow description=\"ICMP-echo-request\" enable=yes remoteip=#{ip['ipaddress']}#{ip['netmask']} protocol=icmpv4:8,any)
      end
    end

    # it would be cool to get these via:
    # https://www.arin.net/resources/whoisrws/whois_api.html
    facebook = "31.13.24.0/21,31.13.64.0/18,66.220.144.0/20,69.63.176.0/20,69.171.224.0/19,74.119.76.0/22,103.4.96.0/22,173.252.64.0/18,204.15.20.0/22"

    ["80","443"].each do |port|
      case node[:hostname]
      when /pww/i
        execute "cerberus_http-tcp-#{port}-ALL" do
          timeout 5
          command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port}-ALL dir=in action=allow description=\"Microsoft IIS webserver ALL access (tcp http #{port})\" enable=yes remoteip=* localport=#{port} protocol=tcp)
        end
      when /qww/i
        execute "cerberus_http-tcp-#{port}-smashrun-internal" do
          timeout 5
          command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port}-smashrun-clients dir=in action=allow description=\"Microsoft IIS webserver smashrun internal access (tcp http #{port})\" enable=yes remoteip=#{list.join(',')} localport=#{port} protocol=tcp)
        end
        execute "cerberus_http-tcp-#{port}-facebook-access" do
          timeout 5
          command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_http-tcp-#{port}-facebook-access dir=in action=allow description=\"Microsoft IIS webserver facebook access (tcp http #{port})\" enable=yes remoteip=#{facebook} localport=#{port} protocol=tcp)
        end
      end
    end

    firewall_rules.each do |rule|
      if rule['protocol'] =~ /ip/
        ["tcp","udp"].each do |multi|
          ip_permit.each do |ip|
            execute "cerberus_#{rule['name']}-#{multi}-#{rule['id']}-#{ip['ipaddress']}#{ip['netmask']}" do
              timeout 5
              command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_#{rule['name']}-#{multi}-#{rule['id']}-#{ip['ipaddress']}#{ip['netmask']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{ip['ipaddress']}#{ip['netmask']} localport=#{rule['id']} protocol=#{multi})
            end
          end
        end
      else
        ip_permit.each do |ip|
          execute "cerberus_#{rule['name']}-#{rule['protocol']}-#{rule['id']}-#{ip['ipaddress']}#{ip['netmask']}" do
            timeout 5
            command %Q(#{node[:kernel][:os_info][:system_directory]}\\netsh advfirewall firewall add rule name=cerberus_#{rule['name']}-#{rule['protocol']}-#{rule['id']}-#{ip['ipaddress']}#{ip['netmask']} dir=in action=allow description=\"#{rule['description']}\" enable=yes remoteip=#{ip['ipaddress']}#{ip['netmask']} localport=#{rule['id']} protocol=#{rule['protocol']})
          end
        end
      end
    end
    log("End import current firewall rules") {level :info}

end


log("end firewall.rb") { level :info }
