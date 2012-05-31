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

      let(:rs1) { ResponseSet.new.tap { |rs| rs.access_code = 'rs1' } }
      let(:rs2) { ResponseSet.new.tap { |rs| rs.access_code = 'rs2' } }

      before do
        [rs1, rs2].each do |rs|
          rs.stub!(:enumerable_as_instrument?).and_return(true)
        end
      end

      it 'converts every response set in turn' do
        rs1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        rs2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))

        ResponseSet.should_receive(:find_each).and_yield(rs1).and_yield(rs2)

        subject.to_a.should == %w(A B C H4 H7)
      end

      it 'skips response sets that are not candidates for enumeration' do
        rs1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        rs2.should_receive(:enumerable_as_instrument?).and_return(false)
        rs2.should_not_receive(:to_mdes_warehouse_records)

        ResponseSet.should_receive(:find_each).and_yield(rs1).and_yield(rs2)

        subject.to_a.should == %w(A B C)
      end

      describe 'when one response set throws an exception' do
        before do
          rs1.should_receive(:to_mdes_warehouse_records).and_raise(IndexError.new('No firsts'))
          rs2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))

          rs1.survey = Survey.new(:title => 'SAQ4')

          ResponseSet.should_receive(:find_each).and_yield(rs1).and_yield(rs2)
        end

        it 'yields a transform error' do
          subject.to_a.first.should be_a(NcsNavigator::Warehouse::TransformError)
        end

        describe 'error message' do
          let(:message) { subject.to_a.first.message }

          it 'includes the response set access code' do
            message.should =~ /response set "rs1"/
          end

          it 'includes the survey title' do
            message.should =~ /for survey "SAQ4"/
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
