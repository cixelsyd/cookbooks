#
# Cookbook Name:: emailer
# Library:: emailer
# Author:: Steven Craig <support@smashrun.com>
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

['rubygems', 'mail'].each do |r|
  begin
    require "#{r}"
  rescue LoadError
    Chef::Log.info("Missing '#{r}'")
  end
end

#begin
#  require "ruby-debug"
#rescue LoadError
#  Chef::Log.info("Missing gem 'ruby-debug'")
#end

class Chef::Recipe::Emailer
  # We can call this with Emailer.send(args)
  def self.send(user,password,fromaddress,toaddress,subject,body,filepath)

    smtp_default = {
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => 'ikickass.com',
      :user_name => "#{user}" + "@gmail.com",
      :password => "#{password}",
      :enable_starttls_auto => true
    }

    Mail.defaults { delivery_method :smtp, smtp_default }

    message = Mail.new do
      from "#{fromaddress}"
      to "#{toaddress}"
      subject "#{subject}"
      body "#{body}"
      add_file "#{filepath}"
    end
    message.deliver!
  end
end
