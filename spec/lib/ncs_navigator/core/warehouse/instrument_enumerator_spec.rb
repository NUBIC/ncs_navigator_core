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

      def stub_rs
        stub('response set').tap { |s| s.stub!(:access_code); s.stub!(:id); s.stub!(:survey) }
      end

      it 'converts every response set in turn' do
        rs1 = stub_rs
        rs1.should_receive(:to_mdes_warehouse_records).and_return(%w(A B C))
        rs2 = stub_rs
        rs2.should_receive(:to_mdes_warehouse_records).and_return(%w(H4 H7))
        [rs1, rs2].each do |m|
          m.stub(:responses).and_return([])
        end

        ResponseSet.should_receive(:find_each).and_yield(rs1).and_yield(rs2)

        subject.to_a.should == %w(A B C H4 H7)
      end
    end
  end
end
