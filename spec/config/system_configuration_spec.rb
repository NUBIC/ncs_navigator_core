require 'spec_helper'

describe NcsNavigatorCore do
  describe '#email_prefix' do
    it 'uniquely identifies the deployment' do
      env_name = ENV['CI_RUBY'] ? 'Ci' : 'Test'
      NcsNavigatorCore.email_prefix.should == "[NCS Navigator Cases SC #{env_name}] "
    end
  end
end
