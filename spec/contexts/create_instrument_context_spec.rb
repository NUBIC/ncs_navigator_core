require 'spec_helper'

describe CreateInstrumentContext do
  let(:p) { Factory(:person) }
  let(:s) { Factory(:survey) }
  let(:rs) { Factory(:response_set, :person => p, :survey => s) }
  let(:responsible_user) { double(:full_name => 'No Name') }

  def run
    CreateInstrumentContext.new(rs, responsible_user).create
  end

  def render(tpl)
    run

    m = rs.instrument_context.to_mustache.tap { |v| v.template = tpl }
    m.render
  end

  describe '#interviewer_name' do
    it "is the responsible user's full name" do
      render('{{interviewer_name}}').should == 'No Name'
    end

    it "is [INTERVIEWER NAME] if the user has no full name" do
      responsible_user.stub!(:full_name => nil)

      render('{{interviewer_name}}').should == '[INTERVIEWER NAME]'
    end
  end

  describe '#p_full_name' do
    it 'is Person#full_name' do
      render('{{p_full_name}}').should == p.full_name
    end

    it "is [UNKNOWN] if the person has no name" do
      rs.person = Factory(:person, :first_name => nil, :last_name => nil)

      render('{{p_full_name}}').should == '[UNKNOWN]'
    end
    
    it "is [UNKNOWN] if the response set does not have a person" do
      rs.update_attribute(:person, nil)

      render('{{p_full_name}}').should == '[UNKNOWN]'
    end
  end

  describe '#p_dob' do
    it "is Person#person_dob" do
      p.update_attribute(:person_dob, '2000-01-01')

      render('{{p_dob}}').should == '2000-01-01'
    end

    it 'is [UNKNOWN] if the response set does not have a person' do
      rs.update_attribute(:person, nil)

      render('{{p_dob}}').should == '[UNKNOWN]'
    end
  end
end
