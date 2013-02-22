# -*- coding: utf-8 -*-

require 'spec_helper'

describe PeopleHelper do
  context "grouping addresses by type and sorting by rank" do
    before do
      @person = Factory(:person)

      @address_a = Factory( :address,
                            :address_rank_code => 1,
                            :address_type_code => 1,
                            :address_one => "123 America Street",
                            :city => "Anytown",
                            :state_code => 23)

      @duplicate_1_address_a = Factory( :address,
                                        :address_rank_code => 1,
                                        :address_type_code => 1,
                                        :address_one => "123 America Street",
                                        :city => "Anytown",
                                        :state_code => 23)

      @duplicate_2_address_a = Factory( :address,
                                        :address_rank_code => 1,
                                        :address_type_code => 1,
                                        :address_one => "123 America Street",
                                        :city => "Anytown",
                                        :state_code => 23)
      @address_b = Factory( :address,
                            :address_rank_code => 1,
                            :address_type_code => 2,
                            :address_one => "654 Elm Avenue",
                            :city => "Shelbyville",
                            :state_code => 15)

      @duplicate_1_address_b = Factory( :address,
                                        :address_rank_code => 1,
                                        :address_type_code => 2,
                                        :address_one => "654 Elm Avenue",
                                        :city => "Shelbyville",
                                        :state_code => 15)

      @duplicate_2_address_b = Factory( :address,
                                        :address_rank_code => 1,
                                        :address_type_code => 2,
                                        :address_one => "654 Elm Avenue",
                                        :city => "Shelbyville",
                                        :state_code => 15)

      @secondary_home_type_address = Factory( :address,
                                              :address_rank_code => 2,
                                              :address_type_code => 1,
                                              :address_one => "4312 Graves Blvd",
                                              :city => "Morton",
                                              :state_code => 34)

      @secondary_business_type_address = Factory( :address,
                                                 :address_rank_code => 2,
                                                 :address_type_code => 2,
                                                 :address_one => "11 Anderson Drive",
                                                 :city => "Folger",
                                                 :state_code => 11)
      @addresses = [@address_a,
                    @duplicate_1_address_a,
                    @duplicate_2_address_a,
                    @address_b,
                    @duplicate_1_address_b,
                    @duplicate_2_address_b,
                    @secondary_home_type_address,
                    @secondary_business_type_address]
      
    end
        

    describe "#group_cme" do 
      it "returns an empty set if contact entries is nil" do
        helper.group_cme(nil).should == {}
      end
      
      it "returns an empty set if contact entries is a set of nils" do
        helper.group_cme([nil, nil, nil]).should == {}
      end

      it "groups address types according to the order defined in the PeopleHelper module" do                
        helper.group_cme(@addresses).should == 
          {1=>[@address_a,@duplicate_1_address_a,
               @duplicate_2_address_a,@secondary_home_type_address],
          2=>[@address_b,@duplicate_1_address_b,
              @duplicate_2_address_b,@secondary_business_type_address]}
      end      
    end
    
    describe "#sort_cme" do
      it "sorts address groups by rank according to the order defined in the PeopleHelper module" do 
        helper.sort_cme(helper.group_cme(@addresses)).should == 
          {1=>[@address_a,@duplicate_1_address_a,
               @duplicate_2_address_a,@secondary_home_type_address],
          2=>[@address_b,@duplicate_1_address_b,
              @duplicate_2_address_b,@secondary_business_type_address]}
      end
    end
    

end

  context "grouping emails by type and sorting by rank" do

    before do
      @person = Factory(:person)

      @email_address_a = Factory( :email,
                                  :email_rank_code => 1,
                                  :email_type_code => 1,
                                  :email => "sjohnson@example.com")

      @email_duplicate_1_address_a = Factory( :email,
                                              :email_rank_code => 1,
                                              :email_type_code => 1,
                                              :email => "sjohnson@example.com")

      @email_duplicate_2_address_a = Factory( :email,
                                              :email_rank_code => 1,
                                              :email_type_code => 1,
                                              :email => "sjohnson@example.com")
      @email_address_b = Factory( :email,
                                  :email_rank_code => 1,
                                  :email_type_code => 2,
                                  :email => "david_billings@example.com")

      @email_duplicate_1_address_b = Factory( :email,
                                              :email_rank_code => 1,
                                              :email_type_code => 2,
                                              :email => "david_billings@example.com")

      @email_duplicate_2_address_b = Factory( :email,
                                              :email_rank_code => 1,
                                              :email_type_code => 2,
                                              :email => "david_billings@example.com")

      @secondary_personal_type_email_address = Factory( :email,
                                                        :email_rank_code => 2,
                                                        :email_type_code => 1,
                                                        :email => "dbillings@example.com")

      @secondary_work_type_email_address = Factory( :email,
                                              :email_rank_code => 2,
                                              :email_type_code => 2,
                                              :email => "johnson_siding@example.com")
      @email_addresses = [@email_address_a,
                          @email_duplicate_1_address_a,
                          @email_duplicate_2_address_a,
                          @email_address_b,
                          @email_duplicate_1_address_b,
                          @email_duplicate_2_address_b,
                          @secondary_personal_type_email_address,
                          @secondary_work_type_email_address]

    end


    describe "#group_cme" do     
      it "groups email types according to the order defined in the PeopleHelper module" do                
        helper.group_cme(@email_addresses).should == 
          {1=>[@email_address_a,@email_duplicate_1_address_a,
               @email_duplicate_2_address_a,@secondary_personal_type_email_address],
          2=>[@email_address_b,@email_duplicate_1_address_b,
              @email_duplicate_2_address_b,@secondary_work_type_email_address]}
      end      
    end
    
    describe "#sort_cme" do
      it "sorts email groups by rank according to the order defined in the PeopleHelper module" do 
        helper.sort_cme(helper.group_cme(@email_addresses)).should == 
          {1=>[@email_address_a,@email_duplicate_1_address_a,
               @email_duplicate_2_address_a,@secondary_personal_type_email_address],
          2=>[@email_address_b,@email_duplicate_1_address_b,
              @email_duplicate_2_address_b,@secondary_work_type_email_address]}
      end
    end
  end

  context "grouping phone numbers by type and sorting by rank" do

    before do
      @person = Factory(:person)

      @phone_a = Factory( :telephone,
                          :phone_rank_code => 1,
                          :phone_type_code => 1,
                          :phone_nbr => "876-545-3322")

      @phone_duplicate_1_a = Factory( :telephone,
                                      :phone_rank_code => 1,
                                      :phone_type_code => 1,
                                      :phone_nbr => "876-545-3322")

      @phone_duplicate_2_a = Factory( :telephone,
                                      :phone_rank_code => 1,
                                      :phone_type_code => 1,
                                      :phone_nbr => "876-545-3322")
      @phone_b = Factory( :telephone,
                          :phone_rank_code => 1,
                          :phone_type_code => 2,
                          :phone_nbr => "242-654-4543")

      @phone_duplicate_1_b = Factory( :telephone,
                                      :phone_rank_code => 1,
                                      :phone_type_code => 2,
                                      :phone_nbr => "242-654-4543")

      @phone_duplicate_2_b = Factory( :telephone,
                                      :phone_rank_code => 1,
                                      :phone_type_code => 2,
                                      :phone_nbr => "242-654-4543")

      @secondary_home_phone = Factory( :telephone,
                                       :phone_rank_code => 2,
                                       :phone_type_code => 1,
                                       :phone_nbr => "434-554-3221")

      @secondary_work_phone = Factory( :telephone,
                                       :phone_rank_code => 2,
                                       :phone_type_code => 1,
                                       :phone_nbr => "745-543-2342")
      @phones = [ @phone_a,
                  @phone_duplicate_1_a,
                  @phone_duplicate_2_a,
                  @phone_b,
                  @phone_duplicate_1_b,
                  @phone_duplicate_2_b,
                  @secondary_home_phone,
                  @secondary_work_phone]
    end

    describe "#group_cme" do     
      it "groups phone types according to the order defined in the PeopleHelper module" do                
        helper.group_cme(@phones).should == 
          {1=>[@phone_a,@phone_duplicate_1_a,
               @phone_duplicate_2_a,@secondary_home_phone,@secondary_work_phone],
          2=>[@phone_b,
              @phone_duplicate_1_b,
              @phone_duplicate_2_b]}
      end      
    end
    
    describe "#sort_cme" do
      it "sorts phone groups by rank according to the order defined in the PeopleHelper module" do 
        helper.sort_cme(helper.group_cme(@phones)).should == 
          {1=>[@phone_a,@phone_duplicate_1_a,
               @phone_duplicate_2_a,@secondary_home_phone,@secondary_work_phone],
          2=>[@phone_b,
              @phone_duplicate_1_b,
              @phone_duplicate_2_b]}
      end
    end

    
        
  end

end
