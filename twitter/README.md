Description
===========

Installs twitter gem and Chef library to provide easy tweeting in recipes via Twitter:tweet()

Requirements
============

Rubygems; works on linux and windows!

Attributes
==========

Tune to set temp and location of your encrypted data bag secret, the name of your encrypted data bag for secret twitter application settings, the name of your twitter application, and any default tags to tweet at.  Note: my windows install still is using old ruby and old chef, so the databag and user attributes are arrays.  This should change.

Usage
=====

Check out full functioned example.rb for details by adding "twitter" and "twitter::example" to the run list, then let chef run twice.  Version 1.0.8 of this cookbook adds support for chef_gem and cleans up a few minor items.  It is still largely unchanged from previous versions.

1
register your [:twitter][:user] app account
https://dev.twitter.com/

2
create and distribute a pre-shared "encrypted_data_bag_secret" file to all nodes (if you do not already have one)
http://wiki.opscode.com/display/chef/Encrypted+Data+Bags

2
create the encrypted [:twitter][:databag] data bag to hold your [:twitter][:user] secret app settings

knife data bag create --secret-file /path/encrypted_data_bag_secret tweeter twitter_name

3
edit json secret [:twitter][:user] app settings inside your [:twitter][:databag] encrypted data bag

knife data bag edit --secret-file  /path/encrypted_data_bag_secret tweeter twitter_name

{
  "id": "twitter_name",
"consumer_key": "string",
"consumer_secret": "string",
"oauth_token": "string",
"oauth_token_secret": "string"
}

4

  node[:twitter][:admin].each { |a|
    Tweeter.tweet(a, "if you use @nikeplus you should have an account on http://bit.ly/smashrun smashrun", settings["consumer_key"], settings["consumer_secret"], settings["oauth_token"], settings["oauth_token_secret"]) }

5
profit