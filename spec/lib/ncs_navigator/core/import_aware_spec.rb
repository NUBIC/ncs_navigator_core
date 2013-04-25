require 'spec_helper'

module NcsNavigator::Core
  describe ImportAware do
    let(:host_class) {
      Class.new do
        include ImportAware
      end
    }

    describe '.importer_mode' do
      [nil, true, false].each do |outer_mode|
        describe "when the starting mode is #{outer_mode.inspect}" do
          before do
            host_class.importer_mode_on = outer_mode
          end

          it 'preserves the original mode after the block' do
            host_class.importer_mode { }
            host_class.importer_mode_on.should == outer_mode
          end

          it 'preserves the original mode after an exception' do
            begin
              host_class.importer_mode do
                fail 'Refused'
              end
            rescue; end

            host_class.importer_mode_on.should == outer_mode
          end

          it 'sets the mode to true for the duration of the block' do
            host_class.importer_mode do
              host_class.should be_in_importer_mode
            end
          end

          it 'returns the return value of the block' do
            host_class.importer_mode { 'foo' }.should == 'foo'
          end
        end
      end
    end

    describe '#in_importer_mode?' do
      [nil, true, false].each do |mode|
        describe "when the mode is #{mode.inspect}" do
          before do
            host_class.importer_mode_on = mode
          end

          it 'reflects the class-level setting' do
            host_class.new.in_importer_mode?.should == mode
          end
        end
      end
    end
  end
end
