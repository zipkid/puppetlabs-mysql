# See README.me for usage.
class mysql::server::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupdirmode = '0700',
  $backupdirowner = 'root',
  $backupdirgroup = 'root',
  $backupcompress = true,
  $backuprotate = 30,
  $ignore_events = true,
  $delete_before_dump = false,
  $backupdatabases = [],
  $file_per_database = false,
  $ensure = 'present',
  $time = ['23', '5'],
  $postscript = false,
  $execpath   = '/usr/bin:/usr/sbin:/bin:/sbin',
  $backuposuser = 'root',
  $backuposgroup = 'root',
) {

  mysql_user { "${backupuser}@localhost":
    ensure        => $ensure,
    password_hash => mysql_password($backuppassword),
    provider      => 'mysql',
    require       => Class['mysql::server::root_password'],
  }

  mysql_grant { "${backupuser}@localhost/*.*":
    ensure     => $ensure,
    user       => "${backupuser}@localhost",
    table      => '*.*',
    privileges => [ 'SELECT', 'RELOAD', 'LOCK TABLES', 'SHOW VIEW', 'PROCESS' ],
    require    => Mysql_user["${backupuser}@localhost"],
  }

  cron { 'mysql-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/mysqlbackup.sh',
    user    => $backuposuser,
    hour    => $time[0],
    minute  => $time[1],
    require => File['mysqlbackup.sh'],
  }

  file { 'mysqlbackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/mysqlbackup.sh',
    mode    => '0700',
    owner   => $backuposuser,
    group   => $backuposgroup,
    content => template('mysql/mysqlbackup.sh.erb'),
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

}
