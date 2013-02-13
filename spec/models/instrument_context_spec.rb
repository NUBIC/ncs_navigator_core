# == Schema Information
# Schema version: 20130212215454
#
# Table name: instrument_contexts
#
#  created_at      :datetime
#  id              :integer          not null, primary key
#  response_set_id :integer          not null
#  updated_at      :datetime
#

require 'spec_helper'

describe InstrumentContext do
  let(:ctx) { InstrumentContext.new }

  def render(ctx, template)
    v = ctx.to_mustache.tap { |v| v.template = template }
    v.render
  end

  describe '#set' do
    it 'sets a key to a value' do
      ctx.set 'foo', 'bar'

      render(ctx, '{{foo}}').should == 'bar'
    end
  end

  describe '#save' do
    it 'saves set context elements' do
      ctx.set 'foo', 'bar'
      ctx.response_set = Factory(:response_set)
      ctx.save!

      render(InstrumentContext.find(ctx.id), '{{foo}}').should == 'bar'
    end
  end
end
