class postfix_rdm (
  $mydomain,
  $recipient_map_name,
  $relayhost,
  $relayhost_port,
  $relayhost_username,
  $relayhost_password,
) {
  file { '/etc/postfix/main.cf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('postfix_rdm/main.cf.erb'),
    notify  => Service['postfix'],
  }

  service { 'postfix':
    ensure => 'running',
    enable => 'true',
  }

  file { '/etc/postfix/sasl_passwd':
    ensure  => file,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => template('postfix_rdm/sasl_passwd.erb'),
    notify  => Exec['postmap_sasl_passwd'],
  }

  exec { 'postmap_sasl_passwd':
    command => '/usr/sbin/postmap /etc/postfix/sasl_passwd',
  }

  file { '/etc/postfix/recipient_canonical':
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template('postfix_rdm/recipient_canonical.erb'),
    notify  => Exec['postmap_recipient_canonical'],
  }

  exec { 'postmap_recipient_canonical':
    command => '/usr/sbin/postmap /etc/postfix/recipient_canonical',
  }

  $sasl_packages = [
    'cyrus-sasl',
    'cyrus-sasl-lib',
    'cyrus-sasl-plain',
  ]

  ensure_packages( $sasl_packages )
}
