require 'spec_helper'

module NcsNavigator::Core::Mdes
  class Blitz < ActiveRecord::Base
    include MdesRecord
    acts_as_mdes_record :public_id_field => :blitz_id,
      :public_id_generator => HumanReadablePublicIdGenerator.new
  end

  describe HumanReadablePublicIdGenerator do
    describe 'ID generation' do
      let(:generator) { HumanReadablePublicIdGenerator.new }

      it 'follows the pattern {3}-{2}-{4}' do
        expected_char_class = '[2-9abcdefhkrstwxyz]'
        generator.generate.should =~
          /^#{expected_char_class}{3}-#{expected_char_class}{2}-#{expected_char_class}{4}$/
      end

      it 'gives a different ID each time' do
        (0..99).collect { generator.generate }.uniq.size.should == 100
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
