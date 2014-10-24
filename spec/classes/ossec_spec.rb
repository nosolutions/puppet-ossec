require 'spec_helper'

describe 'ossec' do

  context 'when running with default parameters' do
    let(:node) { 'foo.example.com' }
    let :facts do
      {
        :osfamily       => 'RedHat',
        :ipaddress_eth0 => '192.168.1.1',
        :network_eth0   => '192.168.1.0',
        :netmask_eth0   => '255.255.255.0',
      }
    end


    it { should create_class('ossec') }
    it { should contain_class('ossec::params') }

    it { should contain_class('atomic') }
  end

  context 'when enable_atomic is false on RedHat' do
    let(:node) { 'foo.example.com' }
    let :facts do
      {
        :osfamily       => 'RedHat',
        :ipaddress_eth0 => '192.168.1.1',
        :network_eth0   => '192.168.1.0',
        :netmask_eth0   => '255.255.255.0',
      }
    end
    let :params do
      {
        'enable_atomic' => false,
      }
    end

    it { should_not contain_class('atomic') }
  end
end
