# -*- coding: utf-8 -*-


require 'spec_helper'

module NcsNavigator::Core::Warehouse
  describe InstrumentEnumerator, :warehouse do
    let(:configuration) {
      NcsNavigator::Warehouse::Configuration.new.tap { |c|
        c.configuration_file = '/foo/b.rb'
        c.output_level = :quiet
        c.log_file = Rails.root + 'log/wh.log'
      }
    }

    it 'is enumerable' do
      InstrumentEnumerator.ancestors.should include(Enumerable)
    end

    describe '.create_transformer' do
      subject { InstrumentEnumerator.create_transformer(configuration) }

      it 'creates a transformer' do
        subject.should respond_to(:transform)
      end

      describe 'the transformer' do
        it 'executes the wrapper script with rails r' do
          subject.exec_and_args.should == [
            'bundle', 'exec', 'rails', 'runner', 'script/instrument_transformer',
            '/foo/b.rb'
          ]
        end

        it 'sets the directory to the rails root' do
          subject.directory.to_s.should == Rails.root.to_s
        end
      end
    end

    describe '#each' do
      subject { InstrumentEnumerator.new(configuration) }

      let(:ins1) { Instrument.new(:instrument_id => 'ins1') }
      let(:ins2) { Instrument.new(:instrument_id => 'ins2') }

      before do
        [ins1, ins2].each do |ins|
          ins.stub!(:enumerable_to_warehouse?).and_return(true)
        end
      end

      it 'converts every response set in turn' do
        ins1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        ins2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))

        Instrument.should_receive(:find_each).and_yield(ins1).and_yield(ins2)

        subject.to_a.should == %w(A B C H4 H7)
      end

      it 'skips response sets that are not candidates for enumeration' do
        ins1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        ins2.should_receive(:enumerable_to_warehouse?).and_return(false)
        ins2.should_not_receive(:to_mdes_warehouse_records)

        Instrument.should_receive(:find_each).and_yield(ins1).and_yield(ins2)

        subject.to_a.should == %w(A B C)
      end

      describe 'when one response set throws an exception' do
        before do
          ins1.should_receive(:to_mdes_warehouse_records).and_raise(IndexError.new('No firsts'))
          ins2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))

          Instrument.should_receive(:find_each).and_yield(ins1).and_yield(ins2)
        end

        it 'yields a transform error' do
          subject.to_a.first.should be_a(NcsNavigator::Warehouse::TransformError)
        end

        describe 'error message' do
          let(:message) { subject.to_a.first.message }

          it 'includes the instrument ID' do
            message.should =~ /instrument "ins1"/
          end

          it 'includes the backtrace' do
            message.should =~ /#{File.basename(__FILE__)}\:\s*\d+/
          end

          it 'includes the exception type' do
            message.should =~ /IndexError/
          end

          it 'includes the exception message' do
            message.should =~ /No firsts/
          end
        end

        it 'enumerates subsequent response sets' do
          subject.to_a[1, 2].should == %w(H4 H7)
        end
      end
    end
  end
end
