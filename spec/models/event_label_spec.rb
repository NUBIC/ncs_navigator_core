require 'spec_helper'

describe EventLabel do
  def el(text)
    EventLabel.new(text)
  end

  describe '#display_text' do
    it 'capitalizes each word' do
      el('foo_bar_1').display_text.should == 'Foo Bar 1'
    end

    it 'does not capitalize "To"' do
      el('abc_to_def').display_text.should == 'Abc to Def'
    end

    it 'does not capitalize "In"' do
      el('one_in_two').display_text.should == 'One in Two'
    end

    describe 'given dashes' do
      it 'removes trailing spaces' do
        el('foo - bar- 1').display_text.should == 'Foo-Bar-1'
      end
    end

    describe 'given "pbs"' do
      it 'upcases "pbs"' do
        el('foo_pbs').display_text.should == 'Foo PBS'
      end

      it 'does not upcase "pbs" in the middle of words' do
        el('abcpbsdef').display_text.should == 'Abcpbsdef'
      end
    end
  end

  describe '#ncs_code' do
    let!(:code) do
      NcsCode.create!(:display_text => 'Foo PBS', :local_code => -42, :list_name => 'EVENT_TYPE_CL1')
    end

    it 'resolves the label to an NCS code' do
      el('foo_pbs').ncs_code.should == code
    end

    it 'can use a display text -> NCS code map' do
      code = NcsCode.new

      el('foo_pbs').ncs_code('Foo PBS' => code).should == code
    end

    it 'returns nil if a code cannot be found in the map' do
      el('foo_pbs').ncs_code({}).should be_nil
    end

    it 'returns nil if a code cannot be found in the database' do
      el('wrong').ncs_code.should be_nil
    end
  end
end
