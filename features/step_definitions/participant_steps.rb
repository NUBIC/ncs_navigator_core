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

Given /^a registered pregnant participant on the ppg1 page$/ do
  steps %Q{
    Given a registered pregnant participant
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
    When I go to the home page
    Then I should see "1 PPG Group 1: Pregnant and Eligible"
    When I follow "PPG Group 1: Pregnant and Eligible"
    Then I should be on the ppg1 page
    And I should see "Bessie Smith"
  }
end