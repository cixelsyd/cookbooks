#
# Cookbook Name:: kronos
# Attributes:: schedule
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

# for reference, this is an example of the JSON inside my chef-server data bags:

# inside databag running_task:
# {"id":"QDB001","task":"deletetranslock,deletefulllock,deletetransstore,deletefullstore,deletedefragdblock,deletepostrefreshlock"}
#
# inside databag task_info:
# {"schedule":"HOURLY","modifier":"1","id":"deletetransrsync","taskargument":"D:\\MSSQL\\sqlscripts\\deploysql_*.log","taskcommand":"c:\\chef\\tmp\\delete.bat","starttime":"00:02:05"}

#      info = { "id" => task["id"],
#        "taskname" => task["id"],
# /tn TaskName Specifies a name for the task.

#        "taskcommand" => task["taskcommand"],
# /tr TaskRun Specifies the program or command that the task runs. Type the fully qualified path and file name of an executable file, script file, or batch file. If you omit the path, Schtasks.exe assumes that the file is in the Systemroot\System32 folder.  Kronos for Windows 2003 concatenates the values "taskcommand" and "taskargument" to form "TaskRun".  Windows 2008 Task Scheduler v2.0 XML requires them to be separate.

#        "taskargument" => task["taskargument"],
# /tr TaskRun Specifies the program or command that the task runs. Type the fully qualified path and file name of an executable file, script file, or batch file. If you omit the path, Schtasks.exe assumes that the file is in the Systemroot\System32 folder.  Kronos for Windows 2003 concatenates the values "taskcommand" and "taskargument" to form "TaskRun".  Windows 2008 Task Scheduler v2.0 XML requires them to be separate.

#        "schedule" => task["schedule"],
# /sc schedule Specifies the schedule type. Valid values for Windows 2003 are MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY, ONCE, ONSTART, ONLOGON, ONIDLE.  Currently, valid values for Kronos on Windows 2008 are MINUTE, DAILY and HOURLY.

#        "modifier" => task["modifier"],
# /mo modifier Specifies how frequently the task runs in its schedule type. This parameter is required for a MONTHLY schedule. This parameter is valid, but optional, for a MINUTE, HOURLY, DAILY, or WEEKLY schedule. The default value is 1.

#        "starttime" => task["starttime"]    
# /st StartTime Specifies the time of day that the task starts in HH:MM:SS 24-hour format. The default value is the current local time when the command completes. The /st parameter is valid with MINUTE, HOURLY, DAILY, WEEKLY, MONTHLY, and ONCE schedules. It is required with a ONCE schedule.


# these are standard
default[:schedule][:author_name] = "Steve Craig"
default[:schedule][:author_email] = "support@smashrun.com"

case node[:platform]
when "windows"
  default[:schedule][:databag_secret] = "C:\\Chef\\encrypted_data_bag_secret"
  default[:schedule][:tempdir] = Chef::Config[:file_cache_path].gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
when "centos","redhat","fedora","ubuntu","debian","arch"
  default[:schedule][:databag_secret] = "/etc/chef/encrypted_data_bag_secret"
  default[:schedule][:tempdir] = Chef::Config[:file_cache_path]
end

default[:schedule][:workingdir] = "#{node[:schedule][:tempdir]}\\tasks"


# templated schedule rules payload file
default[:schedule][:basebat] = "create_task.bat"
default[:schedule][:basebat_template] = "#{node[:schedule][:basebat]}.erb"
default[:schedule][:basexml] = "task.xml"
default[:schedule][:basexml_template] = "#{node[:schedule][:basexml]}.erb"
default[:schedule][:baselog] = "schedule.log"
default[:schedule][:basewiki] = "https://admin.smashrun.com/trac/wiki/"
