require 'spec_helper'

module Psc
  describe ActivityLabel do
    describe '.from_string' do
      it 'constructs labels with MDES versions' do
        l = ActivityLabel.from_string('foo:3.0:bar')

        l.prefix.should == 'foo'
        l.mdes_version.should == '3.0'
        l.content.should == 'bar'
      end

      it 'constructs labels without MDES versions' do
        l = ActivityLabel.from_string('foo:bar')

        l.prefix.should == 'foo'
        l.mdes_version.should be_nil
        l.content.should == 'bar'
      end

      it 'raises on labels with less than two components' do
        lambda { ActivityLabel.from_string('foo') }.should raise_error(ArgumentError)
      end

      it 'raises on labels with more than three components' do
        lambda { ActivityLabel.from_string('a:b:c:d') }.should raise_error(ArgumentError)
      end
    end

    let(:content) { nil }
    let(:mdes_version) { nil }
    let(:prefix) { nil }

    let(:label) { ActivityLabel.new(prefix, mdes_version, content) }

    describe '#has_prefix?' do
      let(:prefix) { 'foo' }

      it 'returns true if the label has the given prefix' do
        label.should have_prefix('foo')
      end

      it 'returns false if the label does not have the given prefix' do
        label.should_not have_prefix('bar')
      end
    end

    describe '#for_mdes_version?' do
      it 'returns true if the label is unversioned' do
        label.mdes_version = nil

        label.should be_for_mdes_version('3.0')
      end

      it "returns true if the label's MDES version matches the given version" do
        label.mdes_version = '3.1'

        label.should be_for_mdes_version('3.1')
      end

      it "returns false if the label's MDES version does not match the given version" do
        label.mdes_version = '2.0'

        label.should_not be_for_mdes_version('3.1')
      end
    end
  end
end
