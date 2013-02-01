# -*- coding: utf-8 -*-


require 'spec_helper'

describe 'Auditing' do
  it 'works for app models' do
    with_versioning { Factory(:participant) }

    Version.where(:item_type => Participant.to_s).should_not be_empty
  end

  context 'with surveyor models' do
    it 'paper_trail works' do
      with_versioning { Factory(:question) }
      Version.where(:item_type => Question.to_s).should_not be_empty
    end

    it "paper_trail works with Survey" do
      with_versioning { Factory(:survey) }
      Version.where(:item_type => Survey.to_s).should_not be_empty
    end
  end
end