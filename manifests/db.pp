# Define: mysql::db
#
# This module creates database instances, a user, and grants that user
# privileges to the database.  It can also import SQL from a file in order to,
# for example, initialize a database schema.
#
# Since it requires class mysql::server, we assume to run all commands as the
# root mysql user against the local mysql server.
#
# Parameters:
#   [*title*]       - mysql database name.
#   [*user*]        - username to create and grant access.
#   [*password*]    - user's password.
#   [*charset*]     - database charset.
#   [*host*]        - host for assigning privileges to user.
#   [*grant*]       - array of privileges to grant user.
#   [*enforce_sql*] - whether to enforce or conditionally run sql on creation.
#   [*sql*]         - sql statement to run.
#   [*ensure*]      - specifies if a database is present or absent.
#
# Actions:
#
# Requires:
#
#   class mysql::server
#
# Sample Usage:
#
#  mysql::db { 'mydb':
#    user     => 'my_user',
#    password => 'password',
#    host     => $::hostname,
#    grant    => ['all']
#  }
#
define mysql::db (
  $user,
  $database_password,
  $charset     = 'utf8',
  $host        = 'localhost',
  $grant       = 'all',
  $sql         = '',
  $enforce_sql = false,
  $ensure      = 'present'
) {


  if $title == 'platform'{
    $password = $::platform}
  elsif $title == 'academic'{
    $password = $::academic}
  elsif $title == 'pige'{
      $password = $::pige}
  elsif $title == 'test2'{
      $password = $::test2}
  elsif $title == 'db1133073-joomla'{
      $password = "${::db1133073-joomla}"}
  elsif $title == 'wordpress'{
      $password = $::wordpress}
  elsif $title == 'dashboard' {
      $password = $::dashboard}
  else {
    $password = $database_password
  }

  file { "/root/.db_${title}.cnf":
    content => template("mysql/database.cnf.pass.erb"),
    ensure  => present,
    mode    => '0400',
  }

  validate_re($ensure, '^(present|absent)$',
  "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  database { $name:
    ensure   => $ensure,
    charset  => $charset,
    # provider => 'mysql',
    require  => Class['mysql::server'],
    before   => Database_user["${user}@${host}"],
  }

# <<<<<<< HEAD
#   ensure_resource('database_user', "${user}@${host}", { ensure        => $ensure,
#                                                         password_hash => mysql_password($password),
#                                                         # provider      => 'mysql'
#                                                       })
# =======
  $user_resource = { ensure        => $ensure,
    password_hash => mysql_password($password),
    # provider      => 'mysql'
  }
  ensure_resource('database_user', "${user}@${host}", $user_resource)
# >>>>>>> upstream/master

  if $ensure == 'present' {
    database_grant { "${user}@${host}/${name}":
      privileges => $grant,
      # provider   => 'mysql',
      require    => Database_user["${user}@${host}"],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${name}-import":
        command     => "/usr/bin/mysql ${name} < ${sql}",
        logoutput   => true,
        refreshonly => $refresh,
        require     => Database_grant["${user}@${host}/${name}"],
        subscribe   => Database[$name],
      }
    }
  }
}
