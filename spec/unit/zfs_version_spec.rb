#!/usr/bin/env ruby

require 'spec_helper'

describe "zfs_version fact" do

  # http://blogs.oracle.com/bobn/entry/live_upgrade_and_zfs_versioning
  #
  # Solaris Release ZPOOL Version ZFS Version
  # Solaris 10 10/08 (u6) 10  3
  # Solaris 10 5/09 (u7)  10  3
  # Solaris 10 10/09 (u8) 15  4
  # Solaris 10 9/10 (u9)  22  4
  # Solaris 10 8/11 (u10) 29  5
  # Solaris 11 11/11 (ga) 33  5

  describe "for Solaris" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("SunOS")
    end

    it "should return correct version on Solaris 10" do
      Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('solaris_10'))
      Facter.fact(:zfs_version).value.should == "3"
    end

    it "should return correct version on Solaris 11" do
      Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('solaris_11'))
      Facter.fact(:zfs_version).value.should == "5"
    end

    it "should return nil if zfs command is not available" do
      Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(nil)
      Facter.fact(:zfs_version).value.should == nil
    end
  end

  ['FreeBSD', 'GNU/kFreeBSD'].each do |kernel|
    describe "for #{kernel}" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns("#{kernel}")
      end

      it "should return correct version on #{kernel} 8.2" do
        Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('freebsd_8.2'))
        Facter.fact(:zfs_version).value.should == "4"
      end

      it "should return correct version on #{kernel} 9.0" do
        Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(my_fixture_read('freebsd_9.0'))
        Facter.fact(:zfs_version).value.should == "5"
      end

      it "should return nil if zfs command is not available" do
        Facter::Util::Resolution.stubs(:exec).with("zfs upgrade -v").returns(nil)
        Facter.fact(:zfs_version).value.should == nil
      end
    end
  end 

  it "should not run on Linux" do
    Facter.fact(:kernel).stubs(:value).returns("Linux")
    Facter.fact(:zfs_version).value.should == nil
  end
end
