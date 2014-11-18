# == Class: ossec::params
#
# The ossec configuration settings.
#
class ossec::params {

  case $::osfamily {
    'RedHat': {
      $server_package_name        = 'ossec-hids-server'
      $server_package_require     = Yumrepo['atomic']
      $server_service_name        = 'ossec-hids'
      $server_service_hasstatus   = true
      $server_service_hasrestart  = true
      $client_package_name        = 'ossec-hids-client'
      $client_package_require     = Yumrepo['atomic']
      $client_service_name        = 'ossec-hids'
      $client_service_hasstatus   = true
      $client_service_hasrestart  = true
    }
    'AIX': {
      $package_source      = 'http://<your package server here'
      $client_package_name = 'ossec-hids-2.8.1-47.aix5.3.ppc.rpm'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only supports osfamily RedHat and AIX")
    }
  }

  $client_id    = fqdn_rand(99999999, 'ossec')
  $email_from   = "ossec@${::fqdn}"
  $email_to     = "root@${::domain}"

}
