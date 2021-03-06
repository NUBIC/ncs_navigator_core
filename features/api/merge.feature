@merge @fieldwork
Feature: Merging data from field clients
  In order to collect data in the field
  Field workers
  need to be able to gather and sync data back to Cases.

  See features/fixtures/fieldwork.json for values used in this test.

  Background:
    Given an authenticated user

  Scenario: New participants are stored
    When I complete the fieldwork set
      | start_date          | 2005-07-01                |
      | end_date            | 2005-07-30                |
      | client_id           | 1234567890                |
      | with                | new_participants.json.erb |
    And the merge runs
    And I go to the participant page

    Then I should see "Bessie Smith"

  Scenario: Changes to contacts, events, and instruments are stored
    Given the participant
      | person/first_name | Bessie              |
      | person/last_name  | Smith               |
      | person/person_id  | registered_with_psc |
    And the event
      | event_id         | 883d5830-91ed-4dd4-9303-903eee737082 |
      | event_type       | Pregnancy Visit 2                    |
      | event_start_date | 2005-07-15                           |
    And the surveys
      | instrument_version | title                 |
      | 1.0                | pregnancy_survey_v1.0 |
    And I complete the fieldwork set
      | start_date | 2005-07-01         |
      | end_date   | 2005-07-30         |
      | client_id  | 1234567890         |
      | with       | fieldwork.json.erb |

    When the merge runs
    And I go to the participant page
    Then I should see "Bessie Smith"

    # event name
    And I should see "Pregnancy Visit 2"

    # event start and end times
    And I should see "13:30"
    And I should see "13:35"

    # event start and end dates
    And I should see "2005-07-17"
    And I should see "2005-07-18"

    # event disposition
    And I should see "Out of sample"

    # instrument name
    And I should see "pregnancy_survey_v1.0"

    # check responses
    When I follow "pregnancy_survey_v1.0"
    Then the "r_1_string_value" field should contain "Jeff January"
    And the "r_2_string_value" field should contain "04/19/2012 13:33"

  Scenario: Responses are merged with respect to participant
    Given the participant
      | person/first_name | Bessie              |
      | person/last_name  | Smith               |
      | person/person_id  | registered_with_psc |
      | p_id              | abc-123-wxyz        |
    And the event
      | event_id         | 883d5830-91ed-4dd4-9303-903eee737082 |
      | event_type       | Pregnancy Visit 2                    |
      | event_start_date | 2005-07-15                           |
    And the surveys
      | instrument_version | title                 |
      | 1.0                | pregnancy_survey_v1.0 |
    And the instrument
      | survey   | pregnancy_survey_v1.0                |
      | event_id | 883d5830-91ed-4dd4-9303-903eee737082 |
      | p_id     | abc-123-wxyz                         |
    And the responses
      | qref | aref | value |
      | 1    | 1    | "Joe" |

    When I complete the fieldwork set
      | start_date        | 2005-07-01                            |
      | end_date          | 2005-07-30                            |
      | client_id         | 1234567890                            |
      | person/first_name | Bessie                                |
      | person/last_name  | Smith                                 |
      | with              | existing_and_new_participant.json.erb |
    And the merge runs
    And I go to the participant page

    Then I should see "April Showers"

    # event name
    And I should see "Pregnancy Visit 2"

    # instrument name
    And I should see "pregnancy_survey_v1.0"

    # check responses
    When I follow "pregnancy_survey_v1.0"
    Then the "r_1_string_value" field should contain "Joe"

  Scenario: New contacts can be linked to new events without instruments
    When I complete the fieldwork set
      | start_date          | 2005-07-01                       |
      | end_date            | 2005-07-30                       |
      | client_id           | 1234567890                       |
      | with                | new_without_instruments.json.erb |
    And the merge runs
    And I go to the participant page

    Then I should see "Bessie Smith"

    # event name
    And I should see "Pregnancy Visit 2"

    # event start and end times
    And I should see "13:30"
    And I should see "13:35"

    # event start and end dates
    And I should see "2005-07-17"
    And I should see "2005-07-18"

    # event disposition
    And I should see "Out of sample"

  Scenario: The field client may create response sets
    Given the participant
      | person/first_name | Bessie              |
      | person/last_name  | Smith               |
      | person/person_id  | registered_with_psc |
    And the event
      | event_id         | 883d5830-91ed-4dd4-9303-903eee737082 |
      | event_type       | Pregnancy Visit 2                    |
      | event_start_date | 2005-07-15                           |
    And the surveys
      | instrument_version | title                 |
      | 1.0                | pregnancy_survey_v1.0 |
    And I complete the fieldwork set
      | start_date | 2005-07-01                 |
      | end_date   | 2005-07-30                 |
      | client_id  | 1234567890                 |
      | with       | new_response_sets.json.erb |
    And there are no response sets for "pregnancy_survey_v1.0"

    When the merge runs
    And I go to the participant page
    And I follow "pregnancy_survey_v1.0"

    Then the "r_1_string_value" field should contain "Jeff January"
    And the "r_2_string_value" field should contain "04/19/2012 13:33"

  Scenario: New contacts can be associated with new people
    Given the surveys
      | instrument_version | title                 |
      | 1.0                | pregnancy_survey_v1.0 |
    And I complete the fieldwork set
      | start_date | 2005-07-01              |
      | end_date   | 2005-07-30              |
      | client_id  | 1234567890              |
      | with       | new_everything.json.erb |
    And there are no response sets for "pregnancy_survey_v1.0"

    When the merge runs
    And I go to the participant page

    Then I should see "Bessie Smith"

    # event name
    And I should see "Pregnancy Visit 2"

    # event start and end times
    And I should see "13:30"
    And I should see "13:35"

    # event start and end dates
    And I should see "2005-07-17"
    And I should see "2005-07-18"

    # event disposition
    # disposition code is 90 - looks like Event.event_disposition_category is not set
    # And I should see "Participant cognitively unable to provide informed consent/complete interview"

    # contact disposition
    And I should see "Out of sample"

    # instrument name
    And I should see "pregnancy_survey_v1.0"

    # survey data
    When I follow "pregnancy_survey_v1.0"

    Then the "r_1_string_value" field should contain "Jeff January"
    And the "r_2_string_value" field should contain "04/19/2012 13:33"
