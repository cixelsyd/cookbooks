#
# Author:: Steve Craig <support@smashrun.com>
# Cookbook Name:: nephele
# Library:: s3lib
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

['rubygems', 'fog'].each do |r|
  begin
    require "#{r}"
  rescue LoadError
    Chef::Log.info("Missing '#{r}'")
  end
end


class Chef::Recipe::S3lib

  # call this with S3lib.sync(args)
  def self.sync(store,origin,bucket,aws_access_key_id,aws_secret_access_key,ispublic)

    base = origin.split(Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact)).last

    # check to see if the storage location exists
    # this is unnecessary if the storage location is AWS
    # only required for playing around with local storage
    unless "#{store}" == "AWS"
      unless File::directory?("#{store}")
        Chef::Log.info("Storage location #{store} missing, creating...")
        Dir.mkdir("#{store}")
      end
    end

    # most likely want to declare a "one-level" max on some base directory locally
    # then pass each of those subs in a block to this
    # will create sub.hostname as href

    storage = Fog::Storage.new({
      :aws_access_key_id      => "#{aws_access_key_id}",
      :aws_secret_access_key  => "#{aws_secret_access_key}",
      :provider               => "#{store}"
    })

    # grab the buckets inside the target storage location
    buckets = storage.directories

    # check to see if the target storage bucket exists
    bucketexist = false
    buckets.each do |d|
      #puts d.key
      if d.key == "#{base}.#{bucket}"
        bucketexist = true
      end
    end
    # create the target storage bucket if it is missing
    unless bucketexist
      Chef::Log.info("#{base}.#{bucket} bucket inside storage #{store} missing, creating...")
      directory = storage.directories.create(:key => "#{base}.#{bucket}")
    end

    directory = storage.directories.get("#{base}.#{bucket}")
    remotefiles = []
    directory.files.each do |k|
      remotefiles << k.key
    end

    unless File.directory?("#{origin}")
      Chef::Log.info("#{origin} local directory does not exist, creating...")
      Dir.mkdir("#{origin}")
    end
    originfiles = Dir.entries("#{origin}")
    # get rid of the "." and ".." cause we don't care
    1.upto(2) { originfiles.shift }
    Chef::Log.info("#{origin} directory inside origin storage contains #{originfiles.length} files.")

    # the origin is authoritative
    # first remove any files that exist on remote storage that do not exist on origin
    deleteresult = remotefiles - originfiles
    unless deleteresult.empty?
      deleteresult.each do |f|
        Chef::Log.info("About to delete #{deleteresult.length} files from remote storage #{base}.#{bucket} #{store}.")
        Chef::Log.info("About to delete file #{f} from remote storage #{base}.#{bucket}...")
        directory.files.head("#{f}").destroy
      end
    else
      Chef::Log.info("Remote storage #{store} does not contain extraneous files.")
    end

    # sync the files missing from origin to remote storage
    syncresult = originfiles - remotefiles
    unless syncresult.empty?
      Chef::Log.info("About to transfer #{syncresult.length} files from origin to remote storage #{base}.#{bucket} #{store}.")
      syncresult.each do |f|
        Chef::Log.info("About to transfer file #{f} from origin to remote storage #{base}.#{bucket}...")
        directory.files.create(:key => f, :body => open("#{origin}/#{f}"), :public => "#{ispublic}")
      end
    else
      Chef::Log.info("Remote storage #{base}.#{bucket} on #{store} already contains all files from origin.")
    end

    Chef::Log.info("Remote storage #{base}.#{bucket} on #{store} is up to date!")
  end #def self.sync

  def self.createbucket(store,bucket,aws_access_key_id,aws_secret_access_key,ispublic)

    # check to see if the storage location exists
    # this is unnecessary if the storage location is AWS
    # only required for playing around with local storage
    unless "#{store}" == "AWS"
      unless File::directory?("#{store}")
        Chef::Log.info("Storage location #{store} missing, creating...")
        Dir.mkdir("#{store}")
      end
    end

    # most likely want to declare a "one-level" max on some base directory locally
    # then pass each of those subs in a block to this
    # will create sub.hostname as href

    storage = Fog::Storage.new({
      :aws_access_key_id      => "#{aws_access_key_id}",
      :aws_secret_access_key  => "#{aws_secret_access_key}",
      :provider               => "#{store}"
    })

    # grab the buckets inside the target storage location
    buckets = storage.directories

    # check to see if the target storage bucket exists
    bucketexist = false
    buckets.each do |d|
      #puts d.key
      if d.key == "#{bucket}"
        bucketexist = true
        Chef::Log.info("#{bucket} bucket exists...")
      end
    end
    # create the target storage bucket if it is missing
    unless bucketexist
      Chef::Log.info("#{bucket} bucket inside storage #{store} missing, creating...")
      directory = storage.directories.create(:key => "#{bucket}")
    end
  end #def self.createbucket

end # class
