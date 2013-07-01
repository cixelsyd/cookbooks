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

log("Begin registry search") {level :debug}
# tasks are stored inside two places inside the registry
# find the GUID references by scanning for kronos-* here:
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree
begin
  require 'win32/registry'
rescue LoadError
end
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

log("Begin Task cleanse") {level :debug}
task_array.each do |hash|
  execute "delete-#{hash[:name]}" do
    cwd "#{node[:schedule][:workingdir]}"
    command %Q(#{node[:kernel][:os_info][:system_directory]}\\schtasks.exe /delete /tn #{hash[:name]} /F)
    action :run
    timeout 60
  end
end
log("End Task cleanse") {level :debug}
log("End delete_2008.rb") { level :info }
