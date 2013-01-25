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

      it "sets the p_info_date attribute to today by default" do
        get :new
        assigns(:person).p_info_date.should == Date.today
      end

      it "sets the p_info_update attribute to today by default" do
        get :new
        assigns(:person).p_info_update.should == Date.today
      end

      it "sets the p_info_source_code attribute to 1 (Person/Self) by default" do
        get :new
        assigns(:person).p_info_source_code.should == Person.person_self_code
      end
    end

    describe "GET edit" do

      let(:person) { Factory(:person, :p_info_source_code => 2, :p_info_date => 1.day.ago.to_date) }

      it "assigns the requested person as @person" do
        get :edit, :id => person.id
        assigns(:person).should eq(person)
      end

      it "sets the p_info_date attribute to the previously known p_info_date" do
        previous = person.p_info_date
        get :edit, :id => person.id
        assigns(:person).p_info_date.should == previous
      end

      it "sets the p_info_date attribute to created_at if not set" do
        per = Factory(:person, :p_info_date => nil, :created_at => 3.days.ago)
        get :edit, :id => per.id
        assigns(:person).p_info_date.should == per.created_at.to_date
      end


      it "sets the p_info_update attribute to today by default" do
        get :edit, :id => person.id
        assigns(:person).p_info_update.should == Date.today
      end

      it "sets the p_info_source_code attribute the previously known p_info_source_code" do
        previous = person.p_info_source_code
        get :edit, :id => person.id
        assigns(:person).p_info_source_code.should == previous
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
