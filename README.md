# OpenCSW #

## Summary ##

This is a Puppet module for managing OpenCSW pkgutil. It is capable of ensuring
pkgutil from OpenCSW installed, and specifying a mirror and some other
parameters.

## Usage ##

    include opencsw

Or

    class { 'opencsw':
      package_source = 'http://get.opencsw.org/now',
      mirror         = 'http://mirror.opencsw.org/opencsw/stable',
      use_gpg        = false,
      use_md5        = false,
    }
