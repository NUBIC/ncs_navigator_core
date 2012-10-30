# -*- coding: utf-8 -*-


require 'spec_helper'

describe PeopleController do

  context "with an authenticated, authorized user" do
    before(:each) do
      login(admin_login) # authorized user
      @person1 = Factory(:person, :first_name => "Jane",  :last_name => "Doe")
      @person2 = Factory(:person, :first_name => "Alice", :last_name => "Doe")
      @person3 = Factory(:person, :first_name => "Annie", :last_name => "Hall")
    end

    describe "GET index" do

      before(:each) do
        Person.count.should == 3
      end

      describe "without search parameters" do
        it "assigns all people as @people" do
          get :index
          assigns[:people].count.should equal(3)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should include @person3
        end
      end

      describe "searching by last name" do
        it "returns complete matches" do
          get :index, :q => { :last_name_start => "Doe" }
          assigns[:people].count.should equal(2)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should_not include @person3
        end

        it "returns partial matches" do
          get :index, :q => { :last_name_start => "Do" }
          assigns[:people].count.should equal(2)
          assigns[:people].should include @person1
          assigns[:people].should include @person2
          assigns[:people].should_not include @person3
        end
      end

      describe "searching by first name" do
        it "returns complete matches" do
          get :index, :q => { :first_name_start => "Jane" }
          assigns[:people].count.should equal(1)
          assigns[:people].should include @person1
          assigns[:people].should_not include @person2
          assigns[:people].should_not include @person3
        end

        it "returns partial matches" do
          get :index, :q => { :first_name_start => "Ja" }
          assigns[:people].count.should equal(1)
          assigns[:people].should include @person1
          assigns[:people].should_not include @person2
          assigns[:people].should_not include @person3
        end
      end
    end

    describe "GET new" do
      it "assigns a new person as @person" do
        get :new
        assigns(:person).should be_a_new(Person)
      end
    end

    context "with a provider" do

      let(:provider) { Factory(:provider) }

      describe "GET new" do
        it "assigns a new provider as @provider" do
          get :new, :provider_id => provider.id
          assigns(:provider).should == provider
        end
      end
    end
  end

  context "with an authenticated yet unauthorized user"  do
    before(:each) do
      login(user_login) # unauthorized user
      @person1 = Factory(:person, :first_name => "Jane",  :last_name => "Doe")
    end

    describe "GET index" do
      before(:each) do
        Person.count.should == 1
      end

      describe "unauthorized attempt to access" do
        it "gives a forbidden status code for attempted at unauthorized access" do
          expect { get :index }.should raise_exception("uncaught throw :warden")
        end
      end
    end
  end

end
