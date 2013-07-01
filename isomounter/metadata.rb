maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures Magic Disc software to mount ISO files on windows machines"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.2"

%w{ windows }.each do |os|
  supports os
end