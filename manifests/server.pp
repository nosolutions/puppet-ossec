# == Class: ossec::server
#
class ossec::server (
  $email_from             = "ossec@${::fqdn}",
  $email_notification     = true,
  $email_to               = "root@${::domain}",
  $firewall_ensure        = 'present',
  $interface              = 'eth0',
  $manage_firewall        = true,
  $package_name           = $ossec::params::server_package_name,
  $package_require        = $ossec::params::server_package_require,
  $port                   = '1514',
  $server_config_replace  = false,
  $service_ensure         = 'running',
  $service_enable         = true,
  $service_name           = $ossec::params::server_service_name,
  $service_hasstatus      = $ossec::params::server_service_hasstatus,
  $service_hasrestart     = $ossec::params::server_service_hasrestart,
  $smtp_server            = 'localhost',
) inherits ossec::params {

  validate_bool($email_notification)
  validate_bool($manage_firewall)
  validate_bool($server_config_replace)

  include ossec

  if $manage_firewall {
    if $interface != 'UNSET' and $interface {
      $iniface        = $interface
      $source_network = getvar("network_${interface}")
      $source_netmask = getvar("netmask_${interface}")
      $source         = "${source_network}/${source_netmask}"
      $client_source  = getvar("ipaddress_${interface}")
    } else {
      $iniface        = undef
      $source         = undef
      $client_source  = undef
    }

    @@firewall { '100 allow OSSEC':
      action  => 'accept',
      proto   => 'udp',
      dport   => $port,
      source  => $client_source,
    }

    Firewall <<| title == '100 allow OSSEC' |>> {
      ensure  => $firewall_ensure,
      iniface => $iniface,
      source  => $source,
    }
  }

  package { 'ossec-hids-server':
    ensure  => 'present',
    name    => $package_name,
    require => $package_require,
  }

  service { 'ossec-hids':
    ensure      => $service_ensure,
    enable      => $service_enable,
    name        => $service_name,
    hasstatus   => $service_hasstatus,
    hasrestart  => $service_hasrestart,
  }

  file { '/var/ossec/etc/ossec-server.conf':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    replace   => $server_config_replace,
    content   => template('ossec/server/ossec-server.conf.erb'),
    require   => Package['ossec-hids-server'],
    notify    => Service['ossec-hids'],
  }

  @@file { '/var/ossec/etc/ossec-agent.conf':
    ensure    => 'file',
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    content   => template('ossec/server/ossec-agent.conf.erb'),
    require   => Package['ossec-hids-client'],
    notify    => Service['ossec-hids'],
    tag       => 'ossec-agent.conf',
  }

}