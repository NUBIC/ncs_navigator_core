Feature: Viewing upcoming appointments
  As an NCS staff member
  In order to know about my upcoming work
  I want to be able to see my upcoming appointments

  Background:
    Given the scheduled participant
      | person/first_name | Dawn                |
      | person/last_name  | Davidson            |
      | person/person_id  | xfda-a78s-h83b      |
      | p_id              | abc-123-wxyz        |
    And the scheduled participant
      | person/first_name | Lisa                |
      | person/last_name  | Pressely            |
      | person/person_id  | he6b-xz2a-24fs      |
      | p_id              | abc-124-wxyz        |
    And the scheduled participant
      | person/first_name | Angela              |
      | person/last_name  | Anderson            |
      | person/person_id  | z6wx-2ya7-ytat      |
      | p_id              | abc-125-wxyz        |
    And the scheduled participant
      | person/first_name | Barbara             |
      | person/last_name  | Barnes              |
      | person/person_id  | byt5-5s89-7a5h      |
      | p_id              | abc-126-wxyz        |
    And the scheduled participant
      | person/first_name | Elaine              |
      | person/last_name  | Edwinson            |
      | person/person_id  | wfx6-4tx4-cf8f      |
      | p_id              | abc-127-wxyz        |
    And the scheduled participant
      | person/first_name | Francine            |
      | person/last_name  | Folgers             |
      | person/person_id  | fy84-54sf-wc3s      |
      | p_id              | abc-128-wxyz        |

  @javascript
  Scenario: The schedule lists my upcoming contacts for the next week
    Given an authenticated user
    When I view my scheduled events for 2013-04-08 to 2013-04-13
    Then I see "Dawn Davidson" scheduled for "Monday April 8" for a "Pregnancy Visit 1" event at "2:45 PM"
    And I see "Elaine Edwinson" scheduled for "Wednesday April 10" for a "Pbs Participant Eligibility Screening" event at "9:30 AM"
    And I see "Francine Folgers" scheduled for "Wednesday April 10" for a "Pbs Participant Eligibility Screening" event at "12:45 PM"
    And I see "Angela Anderson" scheduled for "Wednesday April 10" for a "Pregnancy Visit 1" event at "5:30 PM"
    And I see "Barbara Barnes" scheduled for "Thursday April 11" for a "9 Month" event at "1:15 PM"
    And I see "Lisa Pressely" scheduled for "Thursday April 11" for a "Pregnancy Visit 1" event at "3:45 PM"
    And I see "Dawn Davidson" scheduled for "Thursday April 11" for a "Informed Consent" event
    And I see "Elaine Edwinson" scheduled for "Thursday April 11" for a "Informed Consent" event
    And I see "Francine Folgers" scheduled for "Saturday April 13" for a "Informed Consent" event
