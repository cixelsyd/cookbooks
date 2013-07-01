#
# Cookbook Name:: trac4r
# Library:: tracker
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

['rubygems', 'json', 'trac4r'].each do |r|
  begin
    Gem.clear_paths
    require "#{r}"
  rescue LoadError
    Chef::Log.info("Missing '#{r}'")
  end
end

class Chef::Recipe::Tracker

  # We can call this with Tracker.ticketattach(args)
  def self.ticketattach(url,user,password,ticketid,filename,description,data)
    ticket = ""
      trac = Trac.new("#{url}", "#{user}", "#{password}")
    begin
      ticket = trac.tickets.get(ticketid)
      trac.tickets.put_attachment(ticketid,filename,description,data,true)
    rescue
      puts "error: #{$!}"
    end
  end

  def self.wikicreate(url,user,password,wikipage,wikicontent)
    trac = Trac.new("#{url}", "#{user}", "#{password}")
    begin
      trac.wiki.delete(wikipage)
      trac.wiki.put(wikipage, wikicontent, attributes = { })
    rescue
      puts "error: #{$!}"
    end
  end

  def self.wikiupdate(url,user,password,wikipage,wikicontent)
    trac = Trac.new("#{url}", "#{user}", "#{password}")
    begin
      trac.wiki.put(wikipage, wikicontent, attributes = { })
    rescue
      puts "error: #{$!}"
    end
  end

end
