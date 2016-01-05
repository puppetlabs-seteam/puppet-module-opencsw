# Class: opencsw
#
# Manages OpenCSW and pkgutil on Solaris systems
#
class opencsw (
  $package_source = 'http://get.opencsw.org/now',
  $mirror         = 'http://mirror.opencsw.org/opencsw/stable',
  $use_gpg        = false,
  $use_md5        = false,
  $http_proxy     = undef,
  $https_proxy    = undef,
) {

  # When retrieving pkgutil using a proxy, staging::file requires environment
  # variables be passed in. Similarly, the pkgutil.conf file will require
  # wgetopts be specified to use the proxy.
  if $http_proxy or $https_proxy {
    $environment = ["http_proxy=${http_proxy}", "https_proxy=${https_proxy}"]
    $wgetopts    = "-nv --execute http_proxy=${http_proxy} https_proxy=${https_proxy}"
  } else {
    $environment = undef
    $wgetopts    = '-nv'
  }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  staging::file { 'CSWpkgutil.pkg':
    target      => '/var/sadm/pkg/CSWpkgutil.pkg',
    source      => $package_source,
    before      => Package['CSWpkgutil'],
    environment => $environment,
    wget_option => $wgetopts,
  }

  file { '/var/sadm/install/admin/opencsw-noask':
    ensure => file,
    source => 'puppet:///modules/opencsw/opencsw-noask',
    before => Package['CSWpkgutil'],
  }

  package { 'CSWpkgutil':
    ensure    => 'latest',
    provider  => sun,
    source    => '/var/sadm/pkg/CSWpkgutil.pkg',
    adminfile => '/var/sadm/install/admin/opencsw-noask',
  }

  # Template uses:
  #   - $mirror
  #   - $use_gpg
  #   - $use_md5
  #   - $wgetopts
  file { '/etc/opt/csw/pkgutil.conf':
    ensure  => file,
    content => template('opencsw/pkgutil.conf.erb'),
    require => Package['CSWpkgutil'],
  }

  file { '/opt/csw/etc/pkgutil.conf':
    ensure  => symlink,
    target  => '/etc/opt/csw/pkgutil.conf',
    require => Package['CSWpkgutil'],
  }

  $mangled = regsubst(regsubst($mirror, '(^.*//)', ''), '/', '_', 'G')
  $catalog = "catalog.${mangled}_${::hardwareisa}_${::kernelrelease}"
  exec { 'pkgutil-update':
    command => '/opt/csw/bin/pkgutil -U',
    creates => "/var/opt/csw/pkgutil/${catalog}",
    require => File['/etc/opt/csw/pkgutil.conf'],
  }

}
