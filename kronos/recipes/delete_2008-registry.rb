#
# Cookbook Name:: kronos
# Recipe:: delete_2008
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
# 
# this is a general scheduled task creation engine
# remove and reschedule all tasks each run - takes time but easy
# for windows 2008, chef will not remove non-kronos tasks

# "version": "5.2.3790" is Windows 2003
# "version": "6.0.6002" is Windows 2008
# only_if { "#{node[:kernel][:os_info][:version]}" =~ /^6.0.6002/ }

# on windows 2008, if the template does not change, chef does not reload the task
# this is nice for efficiency; however, it means that if someone deletes the task locally,
# the node[:schedule][:workingdir] folder will need to be deleted before chef will re-create them
# on balance, I like this behaviour
# http://en.wikibooks.org/wiki/Ruby_Programming/Standard_Library/Win32::Registry
#
# I have had a few machines run this for some time, and gradually eat up CPU
# the schtasks.exe eventually times out, after running for an extremely long time
# I saw similar behaviour with my cerberus cookbook when modifying the registry directly
# I am going to leave this inside the cookbook for future reference (it does work)
# and instead do a shorter recipe that calls schtasks.exe to delete each task instead
# the bummer is that this registry cleanse method is super fast

log("begin delete_2008.rb") { level :debug }
log("running delete_2008.rb") { level :info }

# ensure necessary dirs are setup and available
["#{node[:schedule][:tempdir]}", "#{node[:schedule][:workingdir]}"].each do |dir|
  # log("create #{dir} directory if necessary") { level :debug }
  directory "#{dir}" do
    action :create
    not_if { File.exists?("#{dir}") }
    recursive true
  end
end

# this is a hack
# ensure simple batch file for file deletion is on the server
log("create delete.bat if necessary") { level :debug }
template "#{node[:schedule][:tempdir]}\\delete.bat" do
  source "delete.bat.erb"
  variables({
            :author_name => "#{node[:schedule][:author_name]}",
            :author_email => "#{node[:schedule][:author_email]}"
  })
  backup false
end

# blow away all kronos-managed task file settings
# still need to remove registry settings afterwards
execute "#{node[:schedule][:tempdir]}\\delete.bat" do
  cwd "#{node[:schedule][:tempdir]}"
  command  %Q(#{node[:schedule][:tempdir]}\\delete.bat #{node[:kernel][:os_info][:system_directory]}\\Tasks\\kronos-*)
  timeout 30
end


log("Begin registry search") {level :debug}
# tasks are stored inside two places inside the registry
# find the GUID references by scanning for kronos-* here:
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree
require 'win32/registry'
regbase = "Software\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\TaskCache"
raccess = Win32::Registry::KEY_READ
waccess = Win32::Registry::KEY_ALL_ACCESS
task_array = []
task_hash = {}
Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}\\Tree", raccess) do |reg|
  reg.each_key do |k,v|
    if k =~/^kronos/
#      log("found task name #{k}") {level :debug}
      kGUID = Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}\\Tree\\#{k}", raccess)['Id']
      task_hash = {:id => "#{kGUID}", :name => "#{k}"}
      log("found kGUID #{kGUID} for task #{k}") {level :debug}
      guid_path = Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}\\Tasks\\#{kGUID}", raccess)['Path']
#      log("found path #{guid_path} inside kGUID #{kGUID}") {level :debug}
      task_array.push(task_hash)
    end
  end
end
log("End registry search") {level :debug}


# i think this craziness is due to some wierdness surounding the binary nature of the win32 registry
# when i attempted to delete the keys 'in-line' in the loop above, it would always miss one and crap out
# i think they need to be reverse sorted so that they are deleted from the bottom of the tree

log("Begin registry values sort by id") {level :debug}
task_array.sort! { |x,y| y[:id] <=> x[:id] }
#log(task_array.inspect) {level :debug}
log("End registry values sort by id") {level :debug}

log("Begin registry cleanse - GUIDs") {level :debug}
task_array.each do |hash|
  Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}\\Tasks", waccess) do |task_reg|
    log("Delete Tree GUID key #{hash[:id]}") {level :debug}
    task_reg.delete_key("#{hash[:id]}", true)
  end
end
log("End registry cleanse - GUIDs") {level :debug}

log("Begin registry values sort by name") {level :debug}
task_array.sort! { |x,y| y[:name] <=> x[:name] }
#log(task_array.inspect) {level :debug}
log("End registry values sort by name") {level :debug}

log("Begin registry cleanse - Tasks") {level :debug}
task_array.each do |hash|
  Win32::Registry::HKEY_LOCAL_MACHINE.open("#{regbase}\\Tree", waccess) do |task_reg|
    log("Delete Task info key #{hash[:name]}") {level :debug}
    task_reg.delete_key("#{hash[:name]}", true)
  end
end
log("End registry cleanse - Tasks") {level :debug}


log("end delete_2008.rb") { level :info }
