require 'spec_helper'
 
etckeeper_high_pkg_mgr_deb = 'apt'
etckeeper_low_pkg_mgr_deb = 'dpkg'
gitpackage_deb = 'git-core'
etckeeper_package_deb = 'etckeeper'
etckeeper_high_pkg_mgr_red = 'yum'
etckeeper_low_pkg_mgr_red = 'rpm'
gitpackage_red = 'git'
etckeeper_package_red = 'etckeeper'

describe 'etckeeper', :type => 'class' do
    
  context "Should install package, create user, config files and run etckeeper init exec on Debian" do
    let(:facts) {{ :osfamily => 'Debian' }}
    it do
      should contain_class('noconfigpkgs::git')
      should contain_package(etckeeper_package_deb).with_ensure('installed')
      should contain_file('/etc/etckeeper').with(
        'ensure' => 'directory',
        'mode'   => '0755',
      )

      should contain_file('etckeeper.conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/etckeeper/etckeeper.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      ).with_content(/HIGHLEVEL_PACKAGE_MANAGER=#{etckeeper_high_pkg_mgr_deb}/)
      .with_content(/LOWLEVEL_PACKAGE_MANAGER=#{etckeeper_low_pkg_mgr_deb}/)

      should contain_exec('etckeeper-init').with(
        'command' => 'etckeeper init',
        'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'cwd'     => '/etc',
        'creates' => '/etc/.git',
        'require' => [ "Package[#{gitpackage_deb}]", "Package[#{etckeeper_package_deb}]" ],
      )
    end
  end

  context "Should install package, create user, config files and run etckeeper init exec on RedHat" do
    let(:facts) {{ :osfamily => 'RedHat' }}
    it do
      should contain_class('noconfigpkgs::git')
      should contain_package(etckeeper_package_red).with_ensure('installed')
      
      should contain_file('/etc/etckeeper').with(
        'ensure' => 'directory',
        'mode'   => '0755',
      )

      should contain_file('etckeeper.conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/etckeeper/etckeeper.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      ).with_content(/HIGHLEVEL_PACKAGE_MANAGER=#{etckeeper_high_pkg_mgr_red}/)
      .with_content(/LOWLEVEL_PACKAGE_MANAGER=#{etckeeper_low_pkg_mgr_red}/)

      should contain_exec('etckeeper-init').with(
        'command' => 'etckeeper init',
        'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'cwd'     => '/etc',
        'creates' => '/etc/.git',
        'require' => [ "Package[#{gitpackage_red}]", "Package[#{etckeeper_package_red}]" ],
      )
    end
  end

  context "Should fail with unsupported OS family" do
    let(:facts) {{ :osfamily => 'Solaris' }}
    it do
      should raise_error(Puppet::Error, /etckeeper - Unsupported Operating System family: Solaris/)
    end
  end
end
