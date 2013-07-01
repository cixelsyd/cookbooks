#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: twitter
# Recipe:: default
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
# see README.md for Usage

begin
  secret = Chef::EncryptedDataBagItem.load_secret("#{node[:twitter][:databag_secret]}")
  settings = Chef::EncryptedDataBagItem.load("#{node[:twitter][:databag]}", "#{node[:twitter][:user]}", secret)
rescue
end

# tweet
ruby_block "tweet_example" do
  block {
      # add {if,unless} idempotence here
      begin
      node[:twitter][:admin].each { |a|
          Tweeter.tweet(a, "if you use @nikeplus you should have an account on http://bit.ly/smashrun smashrun", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"]) }
      rescue
      end
  }
#  ignore_failure true 
  # lack of idempotence leads to "identical post" 400 error from twitter & bombs chef on failure otherwise
end
