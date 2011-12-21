Given /^a participant exists with a person$/ do
  person = Factory(:person)
  participant = Factory(:participant)
  participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)
end

Given /^a high intensity participant exists with a person$/ do
  person = Factory(:person)
  participant = Factory(:participant, :high_intensity => true)
  participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)
end

Given /^a registered pregnant participant on the ppg1 page with an instrument$/ do
  steps %Q{
    Given a registered pregnant participant
    And a pregnancy visit 1 survey exists
    And ppg1 page is validated
  }
end

Given /^a pregnant participant on the ppg1 page$/ do
  steps %Q{
    Given a pregnant participant
    And ppg1 page is validated
  }
end

Given /^a pregnant participant$/ do
  steps %Q{
    Given valid ncs codes
    And an authenticated user
    And the following pregnant participants:
      | first_name | last_name |
      | Bessie     | Smith     | 
  }
end

Given /^an unregistered pregnant participant$/ do
  steps %Q{
    Given valid ncs codes
    And an authenticated user
    And the following unregistered pregnant participants:
      | first_name | last_name |
      | Bessie     | Smith     | 
  }
end

Given /^a registered unconsented trying participant$/ do
  steps %Q{
    Given valid ncs codes
    And an authenticated user
    And the following registered unconsented trying participants:
    | first_name | last_name | person_id           | 
    | Bessie     | Smith     | registered_with_psc |
  }
end

Given /^a registered pregnant participant on the ppg1 page$/ do
  steps %Q{
    Given a registered pregnant participant
    And ppg1 page is validated
  }
end

Given /^a unregistered participant on the ppg1 page$/ do
  steps %Q{
    Given an unregistered pregnant participant
    And ppg1 page is validated
  }
end

Given /^a registered pregnant participant$/ do
  steps %Q{
    Given valid ncs codes
    And an authenticated user
    And the following pregnant participants:
      | first_name | last_name | person_id           | 
      | Bessie     | Smith     | registered_with_psc | 
  }
end

Given /^ppg1 page is validated$/ do
  steps %Q{
    When I go to the welcome summary page
    Then I should see "1 PPG Group 1: Pregnant and Eligible"
    When I follow "PPG Group 1: Pregnant and Eligible"
    Then I should be on the ppg1 page
    And I should see "Bessie Smith"
  }
end