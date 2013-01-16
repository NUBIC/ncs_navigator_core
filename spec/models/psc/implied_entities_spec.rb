require 'spec_helper'
require 'set'

shared_examples_for 'content fingerprint' do
  describe '#fingerprint' do
    it 'returns the SHA1 of the concatenation of its members' do
      entity.class.members.each do |m|
        entity.send("#{m}=", 'foo')
      end

      values = entity.class.members.map { |m| entity.send(m) }.join('')

      entity.fingerprint.should == Digest::SHA1.hexdigest(values)
    end

    it 'includes fingerprints of constituents' do
      entity.class.members.each do |m|
        entity.send("#{m}=", stub(:fingerprint => 'foo'))
      end

      values = entity.class.members.map { |m| entity.send(m).fingerprint }.join('')

      entity.fingerprint.should == Digest::SHA1.hexdigest(values)
    end
  end
end

shared_examples_for 'an ordered PSC entity' do
  let(:e1) { entity.class.new }
  let(:e2) { entity.class.new }
  let(:set) { SortedSet.new }

  before do
    e1.order = '01_01'
    e2.order = '02_02'
  end

  it 'can be used in a sorted set' do
    set << e2
    set << e1

    set.map { |e| e }.should == [e1, e2]
  end
end

module Psc::ImpliedEntities
  describe Contact do
    let(:entity) { Contact.new }

    include_examples 'content fingerprint'
  end

  describe Event do
    let(:entity) { Event.new }

    include_examples 'content fingerprint'
  end

  describe Instrument do
    let(:entity) { Instrument.new }

    include_examples 'content fingerprint'
    it_should_behave_like 'an ordered PSC entity'
  end

  describe Person do
    let(:entity) { Person.new }

    include_examples 'content fingerprint'
  end

  describe Survey do
    let(:entity) { Survey.new }

    include_examples 'content fingerprint'
    it_should_behave_like 'an ordered PSC entity'
  end

  describe SurveyReference do
    let(:entity) { SurveyReference.new }

    include_examples 'content fingerprint'
  end
end
