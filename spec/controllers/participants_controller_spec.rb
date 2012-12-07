# -*- coding: utf-8 -*-

require 'spec_helper'

describe ParticipantsController do
  before do
    login(admin_login)
  end

  describe 'GET :index' do

    it "defaults being_followed_true to 1" do
      get :index
      assigns[:q].being_followed_true.should be_true
    end

    it "does not override user select of being_followed_true" do
      get :index, :q => { :being_followed_true => 0 }
      assigns[:q].being_followed_true.should_not be_true
    end

  end

  describe 'GET :show' do
    describe ':id resolution' do
      let!(:p1) { Factory(:participant, :id => 9000, :p_id => '4500', :person => Factory(:person, :person_id => 'A')) }
      let!(:p2) { Factory(:participant, :id => 6000, :p_id => '9000', :person => Factory(:person, :person_id => 'B')) }
      let!(:p3) { Factory(:participant, :id => 3000, :p_id => '1500', :person => Factory(:person, :person_id => 'C')) }

      before do
        InstrumentPlan.stub!(:from_schedule).and_return(InstrumentPlan.new)
      end

      it 'resolves as the database ID first' do
        get :show, :id => '9000'

        assigns[:participant].should == p1
      end

      it 'resolves as the participant public ID second' do
        get :show, :id => '1500'

        assigns[:participant].should == p3
      end

      it 'resolves as the participant person ID third' do
        get :show, :id => 'B'

        assigns[:participant].should == p2
      end

      describe 'when the ID cannot be resolved' do
        it 'fails with the standard exception type' do
          expect { get :show, :id => '1' }.
            to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'fails with a useful error message' do
          expect { get :show, :id => 'Z' }.
            to raise_error(/Couldn't find Participant with id=Z or p_id=Z or self person_id=Z/)
        end
      end
    end
  end
end
