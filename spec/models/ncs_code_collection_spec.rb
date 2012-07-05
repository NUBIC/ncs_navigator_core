require 'spec_helper'

describe NcsCodeCollection do
  let(:collection) { NcsCodeCollection.new(query) }
  let(:query) { NcsCode.where(:list_name => 'PSU_CL1') }

  describe '#table' do
    let(:table) { collection.table }

    it 'indexes codes by list name' do
      table['PSU_CL1'].should_not be_nil
    end

    it 'indexes codes by local code' do
      table['PSU_CL1'][-4].should == NcsCode.where(:list_name => 'PSU_CL1', :local_code => -4).first
    end
  end
end
