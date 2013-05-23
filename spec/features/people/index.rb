# -*- coding: utf-8 -*-
require 'spec_helper'

# @todo shouldn't need to use js here.
describe "/people", :clean_with_truncation, :js do
  before(:all) {@old_selector = Capybara.default_selector;Capybara.default_selector = :xpath}
  after(:all) {Capybara.default_selector = @old_selector}

  before :each do
    capybara_login('admin_user')
  end



  let!(:p1) {Factory(:person,
                     :last_name => 'Abbot',
                     :first_name => 'Billy',
                     :person_id => 'C')}

  let!(:p2) {Factory(:person,
                     :last_name => 'Cabbot',
                     :first_name => 'Arnold',
                     :person_id => 'A')}

  let!(:p3) {Factory(:person,
                     :last_name => 'Babbot',
                     :first_name => 'Charlie',
                     :person_id => 'B')}


  it "sorts on various fields" do
    visit '/people'
    within  "//table[@class='records']" do
      within "thead/tr" do
        ["PSU", "First name", "Last name", "Person Identifier"].zip(all('th')).each do
          |text,header|
          header.should have_content(text)
        end
      end

      within "tbody" do
        ["Abbot","Cabbot","Babbot"].zip(all('tr')).each do
          |name,row|
          row.should have_content(name)
        end

        find('//body').click_link("First name")
        ["Cabbot","Abbot","Babbot"].zip(all('tr')).each do
          |name,row|
          row.should have_content(name)
        end

        find('//body').click_link("Last name")
        ["Abbot","Babbot","Cabbot"].zip(all('tr')).each do
          |name,row|
          row.should have_content(name)
        end

        find('//body').click_link("Person Identifier")
        ["Cabbot","Babbot","Abbot"].zip(all('tr')).each do
          |name,row|
          row.should have_content(name)
        end
      end
    end
  end
end
