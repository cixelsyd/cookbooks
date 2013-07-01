#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: hermes
# Recipe:: deltacopy-control.rb
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

log("begin deltacopy-control.rb") { level :debug }
log("running deltacopy-control.rb") { level :info }

begin
  secret = Chef::EncryptedDataBagItem.load_secret("#{node[:twitter][:databag_secret]}")
  settings = Chef::EncryptedDataBagItem.load("#{node[:twitter][:databag]}", "#{node[:twitter][:user]}", secret)
rescue
end

log("service #{node[:deltacopy][:servicename]} control status change to #{node[:deltacopy][:servicestatus]} if necessary ") { level :debug }

case "#{node[:deltacopy][:servicestatus]}"
when "restart"
ruby_block "tweet deltacopy-control" do
  block {
    if node.run_list.include?("role[twitter]")
      unless WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}"}).nil?
      node[:twitter][:admin].each { |a|
        Tweeter.tweet(a, "#{node[:deltacopy][:servicename]} on #{node[:hostname]} instructed to #{node[:deltacopy][:servicestatus]}", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"])
        }
      end
    end
  }
  ignore_failure true 
end
service "#{node[:deltacopy][:servicename]}" do
  action :restart
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}"}) }
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end


when "stop"
ruby_block "tweet deltacopy-control" do
  block {
    if node.run_list.include?("role[twitter]")
      unless WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :started => "false"})
      node[:twitter][:admin].each { |a|
        Tweeter.tweet(a, "#{node[:deltacopy][:servicename]} on #{node[:hostname]} instructed to #{node[:deltacopy][:servicestatus]}", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"])
        }
      end
    end
  }
  ignore_failure true 
end
service "#{node[:deltacopy][:servicename]}" do
  action :stop
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :started => true}) }
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end


when "start"
ruby_block "tweet deltacopy-control" do
  block {
    if node.run_list.include?("role[twitter]")
      unless WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :started => true})
      node[:twitter][:admin].each { |a|
        Tweeter.tweet(a, "#{node[:deltacopy][:servicename]} on #{node[:hostname]} instructed to #{node[:deltacopy][:servicestatus]}", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"])
        }
      end
    end
  }
  ignore_failure true 
end
service "#{node[:deltacopy][:servicename]}" do
  action :start
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :started => false}) }
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end


when "enable"
ruby_block "tweet deltacopy-control" do
  block {
    if node.run_list.include?("role[twitter]")
      unless WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :StartMode => "Auto"})
      node[:twitter][:admin].each { |a|
        Tweeter.tweet(a, "#{node[:deltacopy][:servicename]} on #{node[:hostname]} instructed to #{node[:deltacopy][:servicestatus]}", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"])
        }
      end
    end
  }
  ignore_failure true 
end
service "#{node[:deltacopy][:servicename]}" do
  action :enable
  not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :StartMode =>  "Auto"}) }
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end


when "disable"
ruby_block "tweet deltacopy-control" do
  block {
    if node.run_list.include?("role[twitter]")
      unless WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :StartMode => "Disabled"})
      node[:twitter][:admin].each { |a|
        Tweeter.tweet(a, "#{node[:deltacopy][:servicename]} on #{node[:hostname]} instructed to #{node[:deltacopy][:servicestatus]}", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"])
        }
      end
    end
  }
  ignore_failure true 
end
service "#{node[:deltacopy][:servicename]}" do
  action :disable
  not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "#{node[:deltacopy][:servicename]}", :StartMode =>  "Disabled"}) }
  supports :restart => true, :stop => true, :start => true, :enable => true, :disable => true
end


end


log("end deltacopy-control.rb") { level :info }
