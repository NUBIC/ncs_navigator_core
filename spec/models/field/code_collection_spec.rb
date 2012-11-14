require 'spec_helper'

module Field
  describe CodeCollection do
    let(:cc) { CodeCollection.new }

    describe '#last_modified' do
      let(:dclm) { Time.parse('01-01-2000T00:00:00Z') }
      let(:nclm) { Time.parse('01-01-2000T01:00:00Z') }

      before do
        NcsNavigator::Mdes::DispositionCode.stub!(:last_modified => dclm)
        NcsCode.stub!(:last_modified => nclm)
      end

      describe 'if DispositionCode.last_modified is nil' do
        let(:dclm) { nil }

        it 'returns NcsCode.last_modified' do
          cc.last_modified.should == nclm
        end
      end

      describe 'if NcsCode.last_modified is nil' do
        let(:nclm) { nil }

        it 'returns DispositionCode.last_modified' do
          cc.last_modified.should == dclm
        end
      end
    end
  end
end
