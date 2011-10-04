Feature: Accessing the application
  The application will initially show the upcoming/active records
  In order to have a person easily work with those records
  As a user
  I want to view them when I access the application
  
  Scenario: Accessing a new instance of the application
    Given valid ncs codes
    And an authenticated user
    When I go to the welcome summary page
    Then I should see "NCS Navigator"
    And I should see "Participants"
    And I should see "0 PPG Group 1: Pregnant and Eligible "
    # And I should see "Dwellings"
    # And I should see "No dwellings were found."
    # And I should see "People"
    # And I should see "No people were found."
    
  # Scenario: Accessing an instance of the application with dwelling units without households
  #   Given a dwelling_unit exists with du_type_other: "Test Dwelling"
  #   When I go to the home page
  #   Then I should see "NCS Navigator"
  #   And I should see "Test Dwelling"
  #   And I should see "Household Enumeration"
  
  @javascript
  Scenario: Accessing an instance of the application with participants
    Given valid ncs codes
    And an authenticated user
    And the following pregnant participants:
      | first_name | last_name |
      | Judy       | Garland   |
      | Ma         | Rainey    |
    And a registered pregnant participant
    Then 3 people should exist
    When I go to the welcome summary page
    Then I should see "NCS Navigator"
    And I should see "3 PPG Group 1: Pregnant and Eligible"
    When I follow "PPG Group 1: Pregnant and Eligible"
    Then I should see "Pregnancy Visit 1"
    When I follow "Bessie Smith"
    Then I follow "Initiate Contact"
    Then I should be on the new_person_contact page
    And I should see "Bessie Smith"
    And I should see "Pregnancy Visit 1"
    # And I should see "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"