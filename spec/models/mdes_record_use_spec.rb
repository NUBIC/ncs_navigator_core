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

    it 'has a corresponding column' do
      errors = NcsNavigator::Core::Mdes::MdesRecord.models.collect do |m|
        code_columns = m.columns.collect(&:name).grep(/_code\z/)
        nca_fks = m.ncs_coded_attributes.values.collect(&:foreign_key_name)
        no_column = nca_fks - code_columns

        no_column.collect { |missing_column| "#{m} has a coded attribute declaration for #{missing_column} but that column is not present in the model" }
      end.flatten

      errors.should == []
    end
  end

  describe 'each _code column' do
    it 'has an ncs_coded_attribute declaration' do
      errors = NcsNavigator::Core::Mdes::MdesRecord.models.collect do |m|
        code_columns = m.columns.collect(&:name).grep(/_code\z/)
        nca_fks = m.ncs_coded_attributes.values.collect(&:foreign_key_name)
        no_nca = code_columns - nca_fks

        no_nca.collect { |missing_nca| "#{m} has a column #{missing_nca} but no corresponding ncs_coded_attribute declaration" }
      end.flatten

      errors.should == []
    end
  end
end
