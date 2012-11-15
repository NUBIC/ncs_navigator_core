require 'fileutils'
require 'spec_helper'

module NcsNavigator::Mdes
  describe DispositionCode do
    describe '.last_modified' do
      include FileUtils

      let(:fn) { File.expand_path('../test_disposition_codes.yml', __FILE__) }
      let(:expected_time) { Time.parse('01-01-2000T00:00:00Z') }

      before do
        NcsNavigatorCore.configuration.mdes.source_documents.stub!(:disposition_codes => fn)
        touch fn, :mtime => expected_time
      end

      after do
        rm fn
      end

      describe 'if the disposition codes document exists' do
        it 'returns its modification time' do
          DispositionCode.last_modified.should == expected_time
        end
      end

      describe 'if the disposition codes document does not exist' do
        before do
          NcsNavigatorCore.configuration.mdes.source_documents.stub!(:disposition_codes => '')
        end

        it 'returns nil' do
          DispositionCode.last_modified.should be_nil
        end
      end
    end
  end
end
