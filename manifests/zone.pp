# Bind DNS Server - Zone type
#
# Parameter names lifted from http://tools.ietf.org/html/rfc1035
#
# == Parameters
#
# [*mname*]
#   The <domain-name> of the name server that was the original or primary
#   source of data for this zone.
#
# [*rname*]
#   A <domain-name> which specifies the mailbox of the person responsible
#   for this zone.
#
# [*serial*]
#   The unsigned 32 bit version number of the original copy of the zone.
#
# [*refresh*]
#   A 32 bit time interval before the zone should be refreshed.
#
# [*failed_refresh_retry*]
#   A 32 bit time interval that should elapse before a failed refresh should be
#   retried.
#
# [*expire*]
#  A 32 bit time value that specifies the upper limit on the time interval
#   that can elapse before the zone is no longer authoritative.
#
# [*minimum*]
#   The unsigned 32 bit minimum TTL field that should be exported with any
#   RR from this zone.
#
# [*ttl*]
#   SOA Resource time to live.
#
# [*replace*]
#   If true, the zone file will be created if non-existent, but *never ever
#   touched again*. Even if you update its definition in Puppet, *puppet will
#   refuse to touch the existing file* Only applicable of mode == master
#
# == Variables
#
# [*zone*]
#   The zone name, based off the type instance name.
#
# == Examples
#
#  bind::zone_file { 'foo.com':
#  }
#
define bind::zone($mname = $::fqdn,
    $zone = undef,
    $rname = 'admin',
    $serial = 1,
    $refresh = 86400,
    $failed_refresh_retry = 3600,
    $expire = 86400,
    $minimum = 3600,
    $ttl = 86400,
    $records = undef,
    $mode = 'master',
    $masters = undef,
    $allow_update = undef,
    $forwarders = undef,
    $replace = true,
    $view = false,
) {
  require bind::params

  if $zone {
    $realzone = $zone
  } else {
    $realzone = $name
  }
  $fragment = "01_named.conf.local_zone_fragment_${realzone}"

  if $view {
    $dbfile = "${bind::params::zone_dir}/${view}/db.${realzone}"
    $fragfile = "${bind::params::ncl_v_ffd}/${view}/${fragment}"
    $assemble = "ncl_v_${view}_file_assemble"
  } else {
    $dbfile = "${bind::params::zone_dir}/db.${realzone}"
    $fragfile = "${bind::params::ncl_ffd}/${fragment}"
    $assemble = $bind::params::ncl_file_assemble
  }

    file { $dbfile:
      ensure  => file,
      owner   => $bind::params::user,
      group   => $bind::params::group,
      mode    => '0644',
      replace => $replace,
      require => [
        Package[$bind::params::package],
        File[$bind::params::zone_dir]
      ],
      notify  => Service[$bind::params::service],
    }
  if $mode == 'master' {
    File[ $dbfile ] {
      content => template('bind/zone_file.erb'),
    }
  }

  file { $fragfile:
    ensure  => file,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0644',
    content => template('bind/named.conf.local_zone_fragment.erb'),
    require => File[$bind::params::ncl_ffd],
    notify  => Exec[$assemble],
  }
}

# vim: set ts=2 sw=2 sts=2 tw=0 et:
