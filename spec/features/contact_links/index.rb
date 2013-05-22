# -*- coding: utf-8 -*-
require 'spec_helper'

require File.expand_path('../../../shared/custom_recruitment_strategy', __FILE__)

# @todo shouldn't need to use js here.
describe "/contact_links", :clean_with_truncation, :js do
  before(:all) {@old_selector = Capybara.default_selector;Capybara.default_selector = :xpath}
  after(:all) {Capybara.default_selector = @old_selector}

  before :each do
    capybara_login('admin_user')
  end

  context "for non-PBS" do
    include_context 'custom recruitment strategy'
    let(:recruitment_strategy) { TwoTier.new }

    it "does not list Provider" do
      Factory(:contact_link)
      visit '/contact_links'
      within  "//table[@class='records']" do
        within "thead/tr" do
          ["Type", "Date", "Time", "Person", "Contact Disp", "Event", "Current Staff"].zip(all('th')).each do
            |text,header|
            header.should have_content(text)
          end
        end
      end
    end
  end

  context "for PBS" do
    include_context 'custom recruitment strategy'
    let(:recruitment_strategy) { ProviderBasedSubsample.new }

    let!(:cl1) {Factory(:contact_link,
                       :person  => Factory(:person, :last_name => "Abbot"),
                       :contact => Factory(:contact,
                                           :contact_date_date => Date.parse('10-2-2010'),
                                           :contact_type_code => 3))}

    let!(:cl2) {Factory(:contact_link,
                       :person  => Factory(:person, :last_name => "Cabbot"),
                       :contact => Factory(:contact,
                                           :contact_date_date => Date.parse('10-2-2011'),
                                           :contact_type_code => 2))}

    let!(:cl3) {Factory(:contact_link,
                       :person  => Factory(:person, :last_name => "Babbot"),
                       :contact => Factory(:contact,
                                           :contact_date_date => Date.parse('10-2-2009'),
                                           :contact_type_code => 1))}


    it "sorts on various fields" do
      visit '/contact_links'
      within  "//table[@class='records']" do
        within "thead/tr" do
          ["Type", "Date", "Time", "Person", "Provider", "Contact Disp", "Event", "Current Staff"].zip(all('th')).each do
            |text,header|
            header.should have_content(text)
          end
        end

        within "tbody" do
          ["Abbot","Cabbot","Babbot"].zip(all('tr')).each do
            |name,row|
            row.should have_content(name)
          end

          find('//body').click_link("Type")
          ["Babbot","Cabbot","Abbot"].zip(all('tr')).each do
            |name,row|
            row.should have_content(name)
          end

          find('//body').click_link("Date")
          ["Babbot","Abbot","Cabbot"].zip(all('tr')).each do
            |name,row|
            row.should have_content(name)
          end

          find('//body').click_link("Person")
          ["Abbot","Babbot","Cabbot"].zip(all('tr')).each do
            |name,row|
            row.should have_content(name)
          end
        end
      end
    end
  end
end
