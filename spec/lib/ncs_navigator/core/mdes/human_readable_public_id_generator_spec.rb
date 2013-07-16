require 'spec_helper'

module NcsNavigator::Core::Mdes
  class Blitz < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record :public_id_field => :blitz_id,
      :public_id_generator => HumanReadablePublicIdGenerator.new
  end

  describe HumanReadablePublicIdGenerator do
    describe '#initialize' do
      it 'reports an unknown option' do
        expect { HumanReadablePublicIdGenerator.new(:blazo => 'frob') }.
          to raise_error(/Unknown option :blazo/)
      end

      it 'reports unknown options' do
        expect { HumanReadablePublicIdGenerator.new(:blazo => 'frob', :bank => 'quux') }.
          to raise_error(/Unknown options :blazo, :bank/)
      end
    end

    describe 'ID generation' do
      let(:expected_char_class) { '[2-9abcdefhkrstwxyz]' }

      let(:generator) { HumanReadablePublicIdGenerator.new(options) }
      let(:options) { {} }

      describe 'by default' do
        it 'follows the pattern {3}-{2}-{4}' do
          generator.generate.should =~
            /^#{expected_char_class}{3}-#{expected_char_class}{2}-#{expected_char_class}{4}$/
        end

        it 'gives a different ID each time' do
          (0..99).collect { generator.generate }.uniq.size.should == 100
        end
      end

      describe 'with :pattern' do
        let(:options) { { :pattern => [7, 1, 9, 1] } }

        it 'follows the specified pattern' do
          generator.generate.should =~
            /^#{expected_char_class}{7}-#{expected_char_class}-#{expected_char_class}{9}-#{expected_char_class}$/
        end

        it 'gives a different ID each time' do
          (0..99).collect { generator.generate }.uniq.size.should == 100
        end
      end

      describe 'with :psu' do

        describe "given a valid psu" do
          let(:psu) { NcsNavigatorCore.psu }
          let(:options) { { :psu => psu } }

          it "prepends the last three characters of the PSU plus an underscore to the ID" do
            last_three_digits = psu[(psu.length - 3), psu.length]
            generator.generate.should =~
              /^#{last_three_digits}_#{expected_char_class}{3}-#{expected_char_class}{2}-#{expected_char_class}{4}$/
          end
        end

        describe "given nil" do
          let(:options) { { :psu => nil } }

          it "does not affect the id generation" do
            generator.generate.should =~
              /^#{expected_char_class}{3}-#{expected_char_class}{2}-#{expected_char_class}{4}$/
          end
        end

      end
    end

    describe 'use in an MdesRecord' do
      before do
        ActiveRecord::Schema.define do
          suppress_messages do
            create_table :blitzs, :force => true do |t|
              t.string :name
              t.string :blitz_id
            end
          end
        end
      end

      after do
        ActiveRecord::Schema.define do
          suppress_messages do
            drop_table :blitzs
          end
        end
      end

      it 'gets a new ID when there is a collision' do
        HumanReadablePublicIdGenerator.stub!(:prng).and_return(Random.new(1))
        b1 = Blitz.create!

        HumanReadablePublicIdGenerator.stub!(:prng).and_return(Random.new(1))
        b2 = Blitz.create!

        b1.public_id.should_not == b2.public_id
      end
    end
  end
end
