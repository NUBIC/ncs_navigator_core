require 'spec_helper'

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
  end

  describe Person do
    let(:entity) { Person.new }

    include_examples 'content fingerprint' 
  end

  describe Survey do
    let(:entity) { Survey.new }

    include_examples 'content fingerprint' 
  end

  describe SurveyReference do
    let(:entity) { SurveyReference.new }

    include_examples 'content fingerprint' 
  end
end
