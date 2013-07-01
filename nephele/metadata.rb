maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Installs/Configures nephele, the weather dominator"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.2"

depends           "build-essential", ">= 1.4.0"

%w{ windows fedora redhat }.each do |os|
  supports os
end
