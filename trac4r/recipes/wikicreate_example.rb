#
# Cookbook Name:: trac4r
# Recipe:: example
# Author:: Steven Craig <support@smashrun.com>
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
# example ticket attach restoredb report

begin
  secret = Chef::EncryptedDataBagItem.load_secret("#{node[:trac4r][:databag_secret]}")
  user = Chef::EncryptedDataBagItem.load("#{node[:trac4r][:databag]}", "#{node[:trac4r][:user]}", secret)
#rescue
end

# lets use a template to create these host pages
# that way, nodes will only update their wikipages when their wiki info changes {recipe,role}
templated = nil
begin
  templated = resources(:template => "#{node[:trac4r][:hostwiki_template]}")
rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:trac4r][:wikidir]}\\#{node[:trac4r][:hostwiki]}.txt" do
    source "#{node[:trac4r][:hostwiki_template]}"
    backup false
    variables({
      :fqdn => "#{node[:fqdn].downcase}",
      :host => "#{node[:hostname].downcase}",
      :domain => "#{node[:domain].downcase}",
      :pnpbaseurl => "#{node[:trac4r][:pnpbaseurl]}",
      :kernel_arch => "#{node[:kernel][:machine]}",
      :kernel_name => "#{node[:kernel][:name]}",
      :ipaddress => "#{node[:ipaddress]}",
      :ip6address => "#{node[:ip6address]}",
      :macaddress => "#{node[:macaddress]}",
      :os => "#{node[:os]}",
      :osversion => "#{node[:os_version]}",
      :recipes => node[:recipes],
      :roles => node[:roles],
      :author_name => "#{node[:trac4r][:author_name]}",
      :author_email => "#{node[:trac4r][:author_email]}",
      :hostwiki => "#{node[:trac4r][:hostwiki]}",
      :hostwiki_template => "#{node[:trac4r][:hostwiki_template]}"
    })
    notifies :create, "ruby_block[#{node[:fqdn]} update host wiki page]", :delayed
  end
end

ruby_block "#{node[:fqdn]} update host wiki page" do
  block {
      require "xmlrpc/base64"
    fn = "#{node[:trac4r][:wikidir]}\\#{node[:trac4r][:hostwiki]}.txt"
    case node[:platform]
    when "windows"
      fn = fn.gsub('/', '\\')
    when "redhat","centos","fedora","suse","debian","ubuntu","arch"
      fn = fn.gsub('\\', '/')
    end
    fh = File.new(fn, "rb")
    sdata = fh.read
    data = XMLRPC::Base64.new(sdata)
    Tracker.wikicreate("#{node[:trac4r][:url]}", user["id"], user["password"], "host_#{node[:fqdn].downcase}", data)
  }
  # for some reason, linux seems to require the "create" when the templates change;
  # however, windows seems to properly respect the "nothing" and correctly run only on a change
  case node[:platform]
  when "windows"
    action :nothing
  when "redhat","centos","fedora","suse","debian","ubuntu","arch"
    action :nothing
  end
  #notifies :create, "template[#{node[:trac4r][:wikidir]}\\#{node[:trac4r][:hostwiki]}.txt]", :immediately
  ignore_failure true
end

node[:recipes].each do |r|
  begin
    fn = "#{node[:trac4r][:tempdir]}\\cookbooks\\#{r.split('::')[0]}\\README.md"
    case node[:platform]
    when "windows"
      fn = fn.gsub('/', '\\')
    when "redhat","centos","fedora","suse","debian","ubuntu","arch"
      fn = fn.gsub('\\', '/')
    end
    fh = File.new(fn, "rb")
    data = fh.read
  rescue
  end
  # this bit is CLEARLY suboptimal, because every host will update the readme wiki everytime it changes... oh well
  templated = nil
  begin
    templated = resources(:template => "#{node[:trac4r][:readmewiki_template]}")
  rescue Chef::Exceptions::ResourceNotFound
    templated = template "#{node[:trac4r][:wikidir]}\\#{r.split('::')[0]}-#{node[:trac4r][:readmewiki]}.txt" do
      source "#{node[:trac4r][:readmewiki_template]}"
      backup false
      variables({
        :data => data,
        :cookbook => "#{r.split('::')[0]}",
        :author_name => "#{node[:trac4r][:author_name]}",
        :author_email => "#{node[:trac4r][:author_email]}",
        :readmewiki => "#{node[:trac4r][:readmewiki]}",
        :readmewiki_template => "#{node[:trac4r][:readmewiki_template]}"
      })
      notifies :create, "ruby_block[update #{r} readme wiki page]", :delayed
    end
  end
end

node[:recipes].each do |r|
  ruby_block "update #{r} readme wiki page" do
    block {
      require "xmlrpc/base64"
      fn = "#{node[:trac4r][:wikidir]}\\#{r.split('::')[0]}-#{node[:trac4r][:readmewiki]}.txt"
      case node[:platform]
      when "windows"
        fn = fn.gsub('/', '\\')
      when "redhat","centos","fedora","suse","debian","ubuntu","arch"
        fn = fn.gsub('\\', '/')
      end
      fh = File.new(fn, "rb")
      sdata = fh.read
      data = XMLRPC::Base64.new(sdata)
      Tracker.wikicreate("#{node[:trac4r][:url]}", user["id"], user["password"], "Cookbook_#{r.split('::')[0]}", data)
    }
    # for some reason, linux seems to require the "create" when the templates change;
    # however, windows seems to properly respect the "nothing" and correctly run only on a change
    case node[:platform]
    when "windows"
      action :nothing
    when "redhat","centos","fedora","suse","debian","ubuntu","arch"
      action :nothing
    end
    #notifies :create, "template[#{node[:trac4r][:wikidir]}\\#{r.split('::')[0]}-#{node[:trac4r][:readmewiki]}.txt]", :immediately
    ignore_failure true
  end
end
