Feature: Upload PBS List records from a .csv file
   In order to create new PBS List in the database
   As an authenticated user
   I want to be able to upload a CSV file with the PBS List data

Background:
  Given I am using PBS recruitment
  Given an authenticated user
  And I am on the pbs_lists page

Scenario: Upload PBS List records from a .csv file
	Then I should see "PBS Lists"
  And  I should see "No PBS List records were found"
  And  I should see "Upload PBS List"
  And  I follow "Upload PBS List"
  When I browse for .csv file
  And  I press "Upload"
  Then I should be on the pbs_lists page
  And  I should see "Provider Name"

Scenario: Upload PBS List records without a .csv file
  Then I should be on the pbs_lists page
  And  I should see "PBS Lists"
  And  I should see "No PBS List records were found"
  And  I should see "Upload PBS List"
  And  I follow "Upload PBS List"
  And  I press "Upload"
  Then I should see "You must select a file to upload."
