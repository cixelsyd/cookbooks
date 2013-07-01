#
# Cookbook Name:: kronos
# Recipe:: schedule_2008
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
# "version": "5.2.3790" is Windows 2003
# "version": "6.0.6002" is Windows 2008
# only_if { "#{node[:kernel][:os_info][:version]}" =~ /^6.0.6002/ }

# on windows 2008, if the template does not change, chef does not reload the task
# this is nice for efficiency; however, it means that if someone deletes the task locally,
# the node[:schedule][:workingdir] folder will need to be deleted before chef will re-create them
# on balance, I like this behaviour
#
# Task Scheduler Schema
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa383609(v=vs.85).aspx

log("begin schedule_2008.rb") { level :debug }
log("running schedule_2008.rb") { level :info }

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
# ensure simple batch file for defrag analysis is on the server
# should be moved to the nagios cookbook
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

  # kill any orphaned task xml file that might be "left-over" inside the task directory
  # or any other file inside this directory, for that matter
  # this happens if a task is created, scheduled, and then the data bag entry is removed
  begin
    if node[:schedule][:workingdir]
      Dir.chdir(node[:schedule][:workingdir])
      file = Dir["*"].reject{|o| File.directory?(o)}
      running_task.map!{|x| x + ".xml"}
      delete = file - running_task
      delete.each do |d|
        `del /F /S /Q "#{node[:schedule][:workingdir]}\\#{d}"`
      end
    else
      puts "node[:schedule][:workingdir] is required"
    end
  rescue Exception => e
    Chef::Log.error("Error in cookbook kronos::schedule_2008 #{e}")
  end

  #create individual xml files, one per task
  task_info.each do |task|
    # schedule each task on notification from template
    execute "schedule-#{task["id"]}.xml" do
      cwd "#{node[:schedule][:workingdir]}"
      command %Q(#{node[:kernel][:os_info][:system_directory]}\\schtasks.exe /create /tn kronos-#{task["id"]} /xml #{node[:schedule][:workingdir]}\\#{task["id"]}.xml /F)
      action :nothing
      timeout 60
    end
  
    # chef version branches 0.10.x and 10.x.y handle templates differently
    # unsure exactly what has changed but performance absolutely declined in new branch
    time = Time.new
    windate = time.strftime("%Y-%m-%d")
    wintime = time.strftime("%H:%M:%S")

    templated = nil
    begin
      templated = resources(:template => "#{node[:schedule][:basexml_template]}")
    rescue Chef::Exceptions::ResourceNotFound
      templated = template "#{node[:schedule][:workingdir]}\\#{task["id"]}.xml" do
        source "#{node[:schedule][:basexml_template]}"
        backup false
        variables({
          :task_info => task,
          :windate => windate,
          :wintime => wintime,
          :author_name => "#{node[:schedule][:author_name]}",
          :author_email => "#{node[:schedule][:author_email]}",
          :basexml => "#{node[:schedule][:basexml]}",
          :basexml_template => "#{node[:schedule][:basexml_template]}",
          :baselog => "#{node[:schedule][:baselog]}",
          :basewiki => "#{node[:schedule][:basewiki]}",
          :system_dir => "#{node[:kernel][:os_info][:system_directory]}",
          :working_dir => "#{node[:schedule][:workingdir]}"
        })
        notifies :run, resources(:execute => "schedule-#{task["id"]}.xml"), :delayed
      end
    end
  end

end


log("end schedule_2008.rb") { level :info }
