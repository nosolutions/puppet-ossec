# == Class: ossec::client
#
class ossec::client (
  $repeated_offenders = [],
  $firewall_ensure    = 'present',
  $manage_firewall    = true,
  $package_name       = $ossec::params::client_package_name,
  $service_ensure     = 'running',
  $service_enable     = true,
  $service_name       = $ossec::params::client_service_name,
  $service_hasstatus  = $ossec::params::client_service_hasstatus,
  $service_hasrestart = $ossec::params::client_service_hasrestart,
  $package_require    = $ossec::params::client_package_require,
) inherits ossec::params {

  validate_array($repeated_offenders)
  validate_bool($manage_firewall)

  include ossec

  if $manage_firewall {
    Firewall  <<| title == '100 allow OSSEC server' |>> {
      ensure  => $firewall_ensure,
    }
  }

  package { 'ossec-hids-client':
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

  concat { '/var/ossec/etc/ossec-agent.conf':
    ensure    => 'present',
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    require   => Package['ossec-hids-client'],
    notify    => Service['ossec-hids'],
  }

  concat::fragment { 'ossec-agent.conf-open':
    target  => '/var/ossec/etc/ossec-agent.conf',
    content => template('ossec/client/ossec-agent.conf-open.erb'),
    order   => '00',
  }

  File <<| tag == 'ossec::client' |>>

  concat::fragment { 'ossec-agent.conf-repeated_offenders':
    target  => '/var/ossec/etc/ossec-agent.conf',
    content => template('ossec/client/ossec-agent.conf-repeated_offenders.erb'),
    order   => '10',
  }

  concat::fragment { 'ossec-agent.conf-close':
    target  => '/var/ossec/etc/ossec-agent.conf',
    content => template('ossec/client/ossec-agent.conf-close.erb'),
    order   => '99',
  }
}
