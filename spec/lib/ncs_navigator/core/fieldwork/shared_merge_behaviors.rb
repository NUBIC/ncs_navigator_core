# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../merge_value_generation', __FILE__)

shared_context 'merge' do
  include NcsNavigator::Core::Fieldwork::Adapters

  let(:collection) { entity.underscore.to_s.underscore.pluralize }
  let(:conflicts) { vessel.conflicts }
  let(:uuid) { '2624557A-87AC-4E9B-B2E4-22F1DDFF72D6' }

  def set
    vessel.send(collection).values.first
  end

  def merge
    vessel.merge
  end

  before do
    test_set = {
      uuid => { :original => o, :current => c, :proposed => p }
    }

    vessel.send("#{collection}=", test_set)
  end
end

shared_examples_for 'an entity merge' do |entity|
  let(:klass) { entity.constantize }

  describe "for #{entity} O, C, P" do
    include_context 'merge'

    describe 'if O = C = P = nil' do
      let(:o) { nil }
      let(:c) { nil }
      let(:p) { nil }

      it 'leaves C at nil' do
        merge

        set[:current].should be_nil
      end
    end

    describe 'if O = P = nil and C exists' do
      let(:o) { nil }
      let(:c) { adapt_model(klass.new) }
      let(:p) { nil }

      it 'does not modify C' do
        merge

        set[:current].should_not be_changed
      end
    end

    describe 'if C = P = nil and O exists' do
      let(:o) { adapt_hash(entity.underscore.to_sym, {}) }
      let(:c) { nil }
      let(:p) { nil }

      it 'leaves C at nil' do
        merge

        set[:current].should be_nil
      end
    end

    describe 'if O exists, C is nil, and P is new' do
      let(:o) { adapt_model(klass.new) }
      let(:c) { nil }
      let(:p) { adapt_hash(entity.underscore.to_sym, {}) }

      it 'signals a conflict' do
        merge

        conflicts.should == {
          entity => { uuid => { :self => { :original => o, :current => c, :proposed => p } } }
        }
      end
    end

    describe 'if O exists, C exists, and P is nil' do
      let(:o) { adapt_model(klass.new) }
      let(:c) { adapt_model(klass.new) }
      let(:p) { nil }

      it 'does not modify C' do
        merge

        set[:current].should_not be_changed
      end
    end
  end
end

shared_examples_for 'a resolver' do |entity, property|
  include MergeValueGeneration

  writer = "#{property}="

  let(:values) { gen_values(property, 3) }
  let(:x) { values[0] }
  let(:y) { values[1] }
  let(:z) { values[2] }

  describe 'if O = nil, C = P = X' do
    before do
      c.send(writer, x)
      p.send(writer, x)
    end

    it "sets C##{property} to X" do
      merge

      set[:current].send(property).should == x
    end
  end

  describe 'if O = C = nil, P = X' do
    before do
      p.send(writer, x)
    end

    it "sets C##{property} to X" do
      merge

      set[:current].send(property).should == x
    end
  end

  describe 'if O = nil, C = X, P = Y' do
    before do
      c.send(writer, x)
      p.send(writer, y)
    end

    it 'signals a conflict' do
      merge

      conflicts.should == {
        entity => { uuid => { property => { :original => nil, :current => x, :proposed => y } } }
      }
    end
  end

  describe 'if O = C = P = X' do
    before do
      o.send(writer, x)
      c.send(writer, x)
      p.send(writer, x)
    end

    it "sets C##{property} to X" do
      merge

      set[:current].send(property).should == x
    end
  end

  describe 'if O = C = X, P = Y' do
    before do
      o.send(writer, x)
      c.send(writer, x)
      p.send(writer, y)
    end

    it "sets C##{property} to Y" do
      merge

      set[:current].send(property).should == y
    end
  end

  describe 'if O = X, C = Y, P = X' do
    before do
      o.send(writer, x)
      c.send(writer, y)
      p.send(writer, x)
    end

    it "leaves C##{property} at Y" do
      merge

      set[:current].send(property).should == y
    end
  end

  describe 'if O = X, C = Y, P = Y' do
    before do
      o.send(writer, x)
      c.send(writer, y)
      p.send(writer, y)
    end

    it "sets C##{property} to Y" do
      merge

      set[:current].send(property).should == y
    end
  end

  describe 'if O = P = nil, C = X' do
    before do
      c.send(writer, x)

      # At this point, P is not nil, but all of its values are blank,
      # which is what we want for testing the resolver.
    end

    it "does not modify C##{property}" do
      merge

      set[:current].send(property).should == x
    end

    it 'does not signal a conflict' do
      merge

      conflicts.should be_empty
    end
  end

  describe 'if O = X, C = Y, P = Z' do
    before do
      o.send(writer, x)
      c.send(writer, y)
      p.send(writer, z)
    end

    it 'signals a conflict' do
      merge

      conflicts.should == {
        entity => { uuid => { property => { :original => x, :current => y, :proposed => z } } }
      }
    end
  end
end

shared_examples_for 'an attribute merge' do |entity, property|
  let(:klass) { entity.constantize }

  describe "for #{entity} O, C, P and property #{property}" do
    include MergeValueGeneration

    include_context 'merge'

    describe 'if O = C = nil and P is new' do
      let(:o) { nil }
      let(:c) { nil }
      let(:p) { adapt_hash(entity.underscore.to_sym, { property => value }) }
      let(:value) { gen_values(property, 1).first }

      before do
        merge
      end

      it "sets C to a new #{entity}" do
        set[:current].should be_new_record
      end

      it "sets C##{property}" do
        set[:current].send(property).should == value
      end
    end

    describe 'if C exists and P is new' do
      let(:o) { adapt_hash(entity.underscore.to_sym, {}) }
      let(:c) { adapt_model(klass.new) }
      let(:p) { adapt_hash(entity.underscore.to_sym, {}) }

      it_should_behave_like 'a resolver', entity, property
    end
  end
end
