#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: ismounter
# Recipe:: isomounter
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

log("begin isomounter.rb for #{node[:isomounter][:binary]}") { level :debug }
begin
  require 'win32/registry'
rescue LoadError
end

if
  begin
    Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\').keys.select {|subkey|
      subkey == "MagicDisc #{node[:isomounter][:version]}"
    }.empty?
  end #only install this #{node[:isomounter][:version]} once

  log("running isomounter.rb for #{node[:isomounter][:binary]}") { level :info }
  ["#{node[:isomounter][:tempdir]}"].each do |dir|
    log("create #{dir} directory if necessary") { level :debug }
    directory "#{dir}" do
      action :create
      not_if { File.exists?("#{dir}") }
      recursive true
    end
  end

  log("download #{node[:isomounter][:installer]} from web if necessary") { level :debug }
  remote_file "#{node[:isomounter][:installer]}" do
    action :create
    not_if { File.exists?("#{node[:isomounter][:tempdir]}\\#{node[:isomounter][:installer]}") }
    backup false
    source "#{node[:isomounter][:url]}"
    path "#{node[:isomounter][:tempdir]}\\#{node[:isomounter][:installer]}"
  end

  log("install #{node[:isomounter][:binary]} if necessary") { level :debug }
  execute "#{node[:isomounter][:installer]}" do
    action :run
    timeout 180
    command %Q(#{node[:isomounter][:tempdir]}\\#{node[:isomounter][:installer]} /S)
  end

  #node[:isomounter][:shortcuts].each do |dir|
  #  windows_shortcut "#{dir}\\#{node[:isomounter][:shortcut_name]}.lnk" do
  #    not_if { File.exists?("#{dir}\\#{node[:isomounter][:shortcut_name]}.lnk") }
  #    target "#{node[:isomounter][:installdir]}\\#{node[:isomounter][:binary]}"
  #    description "created by Chef http://bit.ly/isomounter"
  #    action :create
  #  end
  #end

  log("download #{node[:isomounter][:misoexe]} from web if necessary") { level :debug }
  remote_file "#{node[:isomounter][:misoexe]}" do
    action :create
    not_if { File.exists?("#{node[:isomounter][:installdir]}\\#{node[:isomounter][:misoexe]}") }
    backup false
    source "#{node[:isomounter][:misourl]}"
    path "#{node[:isomounter][:installdir]}\\#{node[:isomounter][:misoexe]}"
  end

log("end isomounter.rb") { level :info }
end

log("finish isomounter.rb for #{node[:isomounter][:binary]}") { level :debug }
