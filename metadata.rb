name             'tomcat-vanilla'
maintainer       'Avishai Ish-Shalom'
maintainer_email 'avishai@fewbytes.com'
license          'Apache V2'
description      'Installs/Configures tomcat from vanilla tarball'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.5'

depends "ark"
depends "java"
depends "openssl"
depends "java_ext"
depends "runit"
depends "build-essential"
