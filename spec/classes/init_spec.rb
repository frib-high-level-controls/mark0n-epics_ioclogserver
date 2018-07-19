require 'spec_helper'
describe 'epics_ioclogserver' do
  context 'with default values for all parameters' do
    it { should contain_class('epics_ioclogserver') }
  end
end
