Feature: Accessing the application
  The application will initially show the upcoming/active records
  In order to have a person easily work with those records
  As a user
  I want to view them when I access the application
  
  Scenario: Accessing a new instance of the application
    When I go to the home page
    Then I should see "NCS Navigator"
    And I should see "Upcoming Activities"
    And I should see "Dwellings"
    And I should see "No dwellings were found."
    And I should see "People"
    And I should see "No people were found."
    And I should see "Participants"
    And I should see "No participants were found."
    
  Scenario: Accessing an instance of the application with dwelling units without households
    Given a dwelling_unit exists with du_type_other: "Test Dwelling"
    When I go to the home page
    Then I should see "NCS Navigator"
    And I should see "Test Dwelling"
    And I should see "Household Enumeration"
    
  Scenario: Accessing an instance of the application with participants
    Given the following pregnant participants:
      | first_name | last_name |
      | Judy       | Garland   |
      | Ma         | Rainey    |
      | Bessie     | Smith     |
    And valid ncs codes 
    Then 3 people should exist
    When I go to the home page
    Then I should see "NCS Navigator"
    And I should see "Pregnancy Visit 1"
    And I should see "Judy Garland"
    When I follow "Pregnancy Visit 1"
    Then I should be on the events_person page
    And I should see "Judy Garland"
    And I should see "Instruments for Pregnancy Visit 1"
    And I should see "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"