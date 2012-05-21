Feature: Creating a person record
  The household enumeration may reveal people within the household that will need to be further enumerated for study participation
  In order to have a person with which to associate with other records
  As a user
  I want to be able to create a person record

  Scenario: Creating a new person
    Given an authenticated user
    When I am on the people page
    Then I should see "People"
    And I should see "No people were found."
    And I should see "New Person"
    When I follow "New Person"
    Then I should be on the new person page
    And I should see "New Person"
    When I select "Mr." from "Prefix"
    And I fill in "First Name" with "John"
    And I fill in "Last Name" with "Doe"
    And I select "Male" from "Sex"
    And I select "18-24" from "Age Range"
    And I select "Yes" from "Deceased"
    And I select "Not Hispanic or Latino" from "Ethnic Group"
    And I select "English" from "Language"
    And I select "Married" from "Marital Status"
    And I select "In-person" from "Preferred Contact Method"
    And I select "Yes" from "Planned Move"
    And I select "Address known" from "Move Info"
    And I select "Yes" from "When Move"
    And I select "Yes" from "Tracing"
    And I select "Person/Self" from "Info Source"
    And I press "Submit"
    Then I should see "Person was successfully created."
    And I should be on the people page
    And I should see "John"

  # Scenario: Creating a new person without entering required attributes
  #   Given an authenticated user
  #   When I am on the people page
  #   Then I should see "People"
  #   And I should see "No people were found."
  #   And I should see "New Person"
  #   When I follow "New Person"
  #   Then I should be on the new person page
  #   And I should see "New Person"
  #   When I press "Submit"
  #   Then I should see "2 errors prohibited this Person from being saved"
  #   And I should see "First name can't be blank"
  #   And I should see "Last name can't be blank"
