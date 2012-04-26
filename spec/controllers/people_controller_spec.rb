# encoding: utf-8

require 'spec_helper'

describe PeopleController do

  context "with an authenticated user" do
    before(:each) do
      login(user_login)
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

      describe "json" do

        it "returns the result" do
          get :index, :q => { :first_name_start => "Ja" }, :format => :json
          # response.body.should == [@person1].to_json - does not work since psu_code is a string
          parsed_body = ActiveSupport::JSON.decode(response.body)
          parsed_body.size.should == 1
          parsed_body.first.should include "person"
          person = parsed_body.first["person"]
          person["title"].should == @person1.title
          person["first_name"].should == @person1.first_name
          person["last_name"].should == @person1.last_name
          person["psu_code"].should == @person1.psu_code
        end
      end

    end

  end
end