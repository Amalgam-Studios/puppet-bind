# Bind DNS Server - View type
#
#  bind::view { 'internal':
#    match_clients => [ '192.168.0.0/24' ]
#  }
#
define bind::view(
    $additional_from_auth=undef,
    $additional_from_cache=undef,
    $allow_notify=undef,
    $allow_query=undef,
    $allow_recursion=undef,
    $allow_transfer=undef,
    $allow_update_forwarding=undef,
    $also_notify=undef,
    $alt_transfer_source=undef,
    $alt_transfer_source_v6=undef,
    $auth_nxdomain=undef,
    $cleaning_interval=undef,
    $dialup=undef,
    $disable_algorithms=undef,
    $dnssec_enable=undef,
    $dnssec_lookaside=undef,
    $dnssec_must_be_secure=undef,
    $dual_stack_servers=undef,
    $edns_udp_size=undef,
    $files=undef,
    $forward=undef,
    $forwarders=undef,
    $heartbeat_interval=undef,
    $hostname=undef,
    $ixfr_from_differences=undef,
    $key_directory=undef,
    $lame_ttl=undef,
    $match_clients=undef,
    $match_destinations=undef,
    $match_recursive_only=undef,
    $max_cache_size=undef,
    $max_cache_ttl=undef,
    $max_journal_size=undef,
    $max_ncache_ttl=undef,
    $max_refresh_time=undef,
    $max_retry_time=undef,
    $max_transfer_idle_in=undef,
    $max_transfer_idle_out=undef,
    $max_transfer_time_in=undef,
    $max_transfer_time_out=undef,
    $min_refresh_time=undef,
    $min_retry_time=undef,
    $minimal_responses=undef,
    $multi_master=undef,
    $notify=undef,
    $notify_source=undef,
    $notify_source_v6=undef,
    $preferred_glue=undef,
    $provide_ixfr=undef,
    $query_source=undef,
    $query_source_v6=undef,
    $recursion=undef,
    $request_ixfr=undef,
    $root_delegation_only=undef,
    $rrset_order=undef,
    $sig_validity_interval=undef,
    $sortlist=undef,
    $sig_validity_interval=undef,
    $transfer_format=undef,
    $transfer_source=undef,
    $transfer_source_v6=undef,
    $use_alt_transfer_source=undef,
    $zone_statistics=undef,
) {
  require bind::params

  $header = '00_named.conf.local_view_fragment_header'
  $footer = 'ZZZ_named.conf.local_view_fragment_footer'
  $fragment = "05_named.conf.local_view_fragment_${name}"
  $fragfile = "${bind::params::ncl_ffd}/${fragment}"

  file { "${bind::params::zone_dir}/${name}":
    ensure  => directory,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0750',
    require => [Package[$bind::params::package], File[$bind::params::ncl]],
    recurse => true,
    purge   => true,
  }

  file { "${bind::params::ncl_v_ffd}/${name}":
    ensure  => directory,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0755',
    purge   => true,
    require => File[$bind::params::ncl_v_ffd],
  }

  file { "${bind::params::ncl_v_ffd}/${name}/${header}":
    ensure  => file,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0644',
    content => template('bind/named.conf.local_view_fragment.erb'),
    require => File[ "${bind::params::ncl_v_ffd}/${name}" ],
    notify  => Exec[ "ncl_v_${name}_file_assemble" ],
  }

  file { "${bind::params::ncl_v_ffd}/${name}/${footer}":
    ensure  => file,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0644',
    content => '};
',
    require => File[ "${bind::params::ncl_v_ffd}/${name}" ],
    notify  => Exec[ "ncl_v_${name}_file_assemble" ],
  }

  file { "${bind::params::ncl_ffd}/${fragment}":
    ensure  => file,
    owner   => root,
    group   => $bind::params::group,
    mode    => '0640',
    require => [Package[$bind::params::package], File[$bind::params::conf_dir]],
    notify  => Service[$bind::params::service],
  }

  exec { "ncl_v_${name}_file_assemble":
    refreshonly => true,
    require     => File[ "${bind::params::ncl_v_ffd}/${name}" ],
    notify      => Exec[ $bind::params::ncl_file_assemble ],
    command     => "/bin/cat ${bind::params::ncl_v_ffd}/${name}/* > ${fragfile}"
  }
}

# vim: set ts=2 sw=2 sts=2 tw=0 et:
