#
# Author:: Steven Craig <support@smashrun.com>
# Cookbook Name:: emailer
# Recipe:: example
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

ruby_block "email project foo tag bar build report" do
  block {
    fn = "example.log"
    fh = File.new(fn, "rb")
    sdata = fh.read
    begin
     secret = Chef::EncryptedDataBagItem.load_secret("#{node[:emailer][:databag_secret]}")
     user = Chef::EncryptedDataBagItem.load("#{node[:emailer][:databag]}", "#{node[:emailer][:user]}", secret)
    rescue
    end
    node[:emailer][:to].each { |to|
      Emailer.send(user["id"], user["password"], "#{node[:emailer][:from]}", to, "#{node[:hostname]} build report: project foo tag bar", "#{sdata}", "example.log") }
  }
  ignore_failure true 
end
