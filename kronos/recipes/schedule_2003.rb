#
# Cookbook Name:: kronos
# Recipe:: schedule_2003
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
# unfortunate side effect of this approach is that the "last time run" data is always null - oh well

# "version": "5.2.3790" is Windows 2003
# "version": "6.0.6002" is Windows 2008
# only_if { "#{node[:kernel][:os_info][:version]}" =~ /^6.0.6002/ }

log("begin schedule_2003.rb") { level :debug }
log("running schedule_2003.rb") { level :info }

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

# this is a hack
# ensure simple batch file for defrag analysis is on the server
log("create defragwrap.bat if necessary") { level :debug }
template "#{node[:schedule][:tempdir]}\\defragwrap.bat" do
  source "defragwrap.bat.erb"
  variables({
            :author_name => "#{node[:schedule][:author_name]}",
            :author_email => "#{node[:schedule][:author_email]}",
            :sysdir => "#{node[:kernel][:os_info][:system_directory]}"
  })
  backup false
end

# organize tasks
log("begin organize tasks") { level :debug }

# running_task holds the comma-separated list of tasks that run on the host
# task_info holds location and file information specific to the individual task
running_task = []
task_info = []

search(:running_task, "id:#{node[:hostname]}") do |host|
  running_task << host["task"].split(",")
  running_task.flatten!
  running_task.each do |taskname|
    search(:task_info, "id:#{taskname}") do |task|
      info = { "id" => task["id"],
        "taskname" => task["id"],
        "taskrun" => task["taskrun"],
        "taskcommand" => task["taskcommand"],
        "taskargument" => task["taskargument"],
        "schedule" => task["schedule"],
        "modifier" => task["modifier"],
        "starttime" => task["starttime"]    
      }
      task_info << info
    end
  end
  #log(task_info.inspect) {level :debug}
  # create one batchfile full of all tasks
  templated = nil
  begin
    templated = resources(:template => "#{node[:schedule][:basebat_template]}")
  rescue Chef::Exceptions::ResourceNotFound
    templated = template "#{node[:schedule][:tempdir]}\\#{node[:schedule][:basebat]}" do
      source "#{node[:schedule][:basebat_template]}"
      backup false
      variables({
        :task_info => task_info,
        :author_name => "#{node[:schedule][:author_name]}",
        :author_email => "#{node[:schedule][:author_email]}",
        :basebat => "#{node[:schedule][:basebat]}",
        :basebat_template => "#{node[:schedule][:basebat_template]}",
        :baselog => "#{node[:schedule][:baselog]}",
        :system_dir => "#{node[:kernel][:os_info][:system_directory]}",
        :working_dir => "#{node[:schedule][:workingdir]}"
      })
    end
  end
  # schedule tasks  
  execute "#{node[:schedule][:basebat]}" do
    cwd "#{node[:schedule][:tempdir]}"
    command "#{node[:schedule][:tempdir]}\\#{node[:schedule][:basebat]} #{node[:schedule][:baselog]}"
    # this is always executed, so chef always deletes and re-schedules tasks each time
    # sub-optimal; however, doesn't seem like a measurable performance hit
    timeout 300
  end
end


log("end schedule_2003.rb") { level :info }
