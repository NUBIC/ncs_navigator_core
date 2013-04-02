require 'spec_helper'

describe 'Every MdesRecord model in Cases' do
  describe 'each coded attribute' do
    NcsNavigator::Core::Mdes::SUPPORTED_VERSIONS.each do |mdes_version|
      it "has exactly one code list specified for MDES version #{mdes_version}" do
        errors = NcsNavigator::Core::Mdes::MdesRecord.models.
          collect { |model_class| model_class.ncs_coded_attributes.values }.flatten.
          collect { |nca|
            begin
              nca.list_name(mdes_version)
              nil
            rescue RuntimeError => e
              e.to_s
            end
            }.compact

        errors.should == []
      end
    end
  end
end
