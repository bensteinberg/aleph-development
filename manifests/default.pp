exec { 'update':
  command => 'sudo aptitude update',
  path => '/usr/bin',
}

package {['emacs', 'vim', 'make', 'git', 'wget', 'unzip', 'bzip2', 'alien', 'libjansson4']:
  ensure => 'present',
  require => Exec['update'],
}

exec { 'aleph':
  command => 'git clone https://github.com/tehn/aleph.git',
  path => '/usr/bin',
  require => Package['git'],
}

exec { 'get_jansson':
  command => 'cp /vagrant/libjansson.tar.gz /home/vagrant',
  path => '/bin',
}

exec { 'install_jansson':
  command => 'sudo alien -i /home/vagrant/libjansson.tar.gz',
  path => '/usr/bin',
  require => [ Exec['get_jansson'], Package['alien'] ],
  cwd => '/home/vagrant',
  timeout => 1800,
}

exec { 'get_atmel':
  command => 'cp /vagrant/avr32*.tar.gz /home/vagrant ; cp /vagrant/atmel*.zip /home/vagrant',
  path => '/bin',
}

exec { 'unzip_atmel':
  command => 'unzip atmel-headers-6.1.3.1475.zip',
  path => '/usr/bin',
  require => [ Package['unzip'], Exec['get_atmel'] ],
  cwd => '/home/vagrant',
}

exec { 'untar_atmel':
  command => 'tar xvzf avr32-gnu-toolchain-3.4.2.435-linux.any.x86_64.tar.gz',
  path => '/bin',
  require => Exec['get_atmel'],
  cwd => '/home/vagrant',
}

exec { 'get_blackfin':
  command => 'wget http://downloads.sourceforge.net/project/adi-toolchain/2013R1/2013R1-RC1/x86_64/blackfin-toolchain-elf-gcc-4.3-2013R1-RC1.x86_64.tar.bz2',
  path => '/usr/bin',
  require => Package['wget'],
  timeout => 1800,
}

exec { 'unzip_blackfin':
  command => 'tar -xjf blackfin-toolchain-elf-gcc-4.3-2013R1-RC1.x86_64.tar.bz2',
  path => '/bin',
  require => [ Exec['get_blackfin'], Package['bzip2'] ],
  timeout => 1800,
}

exec { 'update_path':
  command => 'echo "PATH=\$PATH:~/avr32-gnu-toolchain/bin:~/opt/uClinux/bfin-elf/bin" >> /home/vagrant/.bashrc',
  path => '/bin',
}

exec { 'setup_avr32':
  command => 'mv avr32-gnu-toolchain-linux_x86_64 avr32-gnu-toolchain ; cp -R /atmel-headers-6.1.3.1475/avr avr32-gnu-toolchain/avr32/include/ ; cp -R atmel-headers-6.1.3.1475/avr32 avr32-gnu-toolchain/avr32/include/',
  path => '/bin',
  require => [ Exec['untar_atmel'], Exec['unzip_atmel'] ],
  cwd => '/home/vagrant',
}

exec { 'chown':
  command => 'chown -R vagrant.vagrant /home/vagrant',
  path => '/bin',
  require => [ Exec['setup_avr32'], Exec['aleph'] ],
}
