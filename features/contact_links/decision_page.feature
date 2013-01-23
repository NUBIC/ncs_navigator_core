Feature: After completing an instrument for a contact
  The user will need to make a decision to either
  Administer another instrument associated with the event
  Enter information about the contact
  Or end the interaction with the participant

  Scenario: Creating a new participant visit record
  Given an authenticated user
  And a contact record without an associated participant visit record
  When I am on the decision_page_contact_link page
  And I should see "Instruments and Activities"
  And I should see "Create Participant Record of Visit"
  And I should see "Enter information about the Visit"
  And I should see "Complete Contact Record"
  And I should see "Complete Event Record"
  When I follow "Create Participant Record of Visit"
  Then I should be on the new_participant_visit_record page


  Scenario: Updating a participant visit record
  Given an authenticated user
  And a contact record with an associated participant visit record
  When I am on the decision_page_contact_link page
  And I should see "Update Participant Record of Visit"
  When I follow "Update Participant Record of Visit"
  Then I should be on the edit_participant_visit_record page
