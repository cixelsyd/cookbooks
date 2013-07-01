maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures tweeter the twitterer for windows redhat centos fedora ubuntu debian"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.8"

%w{ centos redhat fedora ubuntu debian arch windows }.each do |os|
  supports os
end