#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: twitter
# Library:: twitter
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

['rubygems', 'twitter'].each do |r|
  begin
    Gem.clear_paths
    require "#{r}"
  rescue LoadError
    Chef::Log.info("Missing '#{r}'")
  end
end

class Chef::Recipe::Tweeter

  # We can call this with Tweeter.tweet(args)
  def self.tweet(reply,twit,consumer_key,consumer_secret,oauth_token,oauth_token_secret)
    Twitter.configure do |config|
      config.consumer_key = "#{consumer_key}"
      config.consumer_secret = "#{consumer_secret}"
      config.oauth_token = "#{oauth_token}"
      config.oauth_token_secret = "#{oauth_token_secret}"
    end
    client = Twitter::Client.new
    client.update("#{reply}" + " #{twit}")
  end
end
