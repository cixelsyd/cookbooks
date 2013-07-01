maintainer       "Smashrun, Inc."
maintainer_email "support@smashrun.com"
license          "Apache 2.0"
description      "Kronos manages windows scheduled tasks"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.4"
depends           "reginjector", ">= 0.1.0"

%w{ windows }.each do |os|
  supports os
end