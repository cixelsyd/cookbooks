#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: reginjector
# Recipe:: injection.rb
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

log("begin reginjector.rb") { level :debug }
log("running reginjector.rb") { level :info }

["#{node[:reginjector][:tempdir]}", "#{node[:reginjector][:workingdir]}"].each do |dir|
  directory "#{dir}" do
    action :create
    not_if { File.exists?("#{dir}") }
    recursive true
  end
end


# create templated batch file for reg file deployment
log("create #{node[:reginjector][:tempdir]}\\#{node[:reginjector][:regdeploybat]} if necessary") { level :debug }
templated = nil
begin
  templated = resources(:template => "#{node[:reginjector][:regdeploybat_template]}")
rescue Chef::Exceptions::ResourceNotFound
  templated = template "#{node[:reginjector][:tempdir]}\\#{node[:reginjector][:regdeploybat]}" do
    source "#{node[:reginjector][:regdeploybat_template]}"
    backup false
    variables({
      :author_name => "#{node[:reginjector][:author_name]}",
      :author_email => "#{node[:reginjector][:author_email]}",
      :working_dir => "#{node[:reginjector][:workingdir]}",
      :system_dir => "#{node[:kernel][:os_info][:system_directory]}",
      :regdeploybat => "#{node[:reginjector][:regdeploybat]}",
      :regdeploybat_template => "#{node[:reginjector][:regdeploybat_template]}"
    })
  end
end

node[:reginjector][:payload].each do |k|

  # execute reg payload file if instructed by a template change
  execute "#{node[:reginjector][:regdeploybat]}_#{k}" do
    cwd "#{node[:reginjector][:tempdir]}"
    command "#{node[:reginjector][:tempdir]}\\#{node[:reginjector][:regdeploybat]} #{k}.reg reginjector-#{k}.log"
    timeout 30
    action :run
    not_if { File.exists?("#{node[:reginjector][:workingdir]}\\reginjector-#{k}.log") }
    # this is a hack and I don't like it - but the batch file exits code 42 (even though I set it to zero)
    ignore_failure true
  end

  # create templated reg payload file for reginjector
  log("create #{node[:reginjector][:workingdir]}\\#{k}.reg if necessary") { level :debug }
  templated = nil
  begin
    templated = resources(:template => "#{k}.reg")
  rescue Chef::Exceptions::ResourceNotFound
    templated = template "#{node[:reginjector][:workingdir]}\\#{k}.reg" do
      source "#{k}.reg.erb"
      variables({
        :author_name => "#{node[:reginjector][:author_name]}",
        :author_email => "#{node[:reginjector][:author_email]}",
        :regeditor_version => "#{node[:reginjector][:regeditor_version]}"
      })
      notifies :run, resources(:execute => "#{node[:reginjector][:regdeploybat]}_#{k}"), :immediately
    end
  end

end
log("end reginjector.rb") { level :info }
