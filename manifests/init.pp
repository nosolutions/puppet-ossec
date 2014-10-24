# == Class: ossec
#
class ossec (
  $enable_atomic = 'true',
  ) inherits ossec::params {

  validate_bool($enable_atomic)

  if $::osfamily == 'RedHat' and $enable_atomic == 'true' {
      include atomic
  }
}
