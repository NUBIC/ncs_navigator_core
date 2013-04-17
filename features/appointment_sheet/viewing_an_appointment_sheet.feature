Feature: Viewing an appointment sheet
  As an NCS staff member
  In order to conduct an appointment
  I want an aggregation of relevant appointment information

  Background:
    Given the scheduled participant
      | person/first_name | Dawn                |
      | person/last_name  | Davidson            |
      | person/person_id  | xfda-a78s-h83b      |
      | p_id              | abc-123-wxyz        |
    And whose scheduled event is
      | event_id         | 883d5830-91ed-4dd4-9303-903eee737082 |
      | event_type       | Pregnancy Visit 1                    |
      | event_start_date | 2013-03-26                           |
    And whose address is
      | address_rank_code | 1             |
      | address_one       | 123 73rd Ave. |
      | address_two       | Apt. 1C       |
      | city              | Rockville     |
      | state             | 21            |
      | zip               | 20850         |
    And whose cellphone is 444-342-3654
    And whose homephone is 301-908-1212
    And has a general consent
    And who has Consent to collect environmental samples
    And who has Consent to collect biospecimens
    And speaks english
    And whose child is
      | person/first_name | Harley              |
      | person/last_name  | Davidson            |
      | person/person_id  | registered_with_psc |
      | person/person_dob| 2012-08-12           |
      | p_id              | ewx-323-pelc        |
    And is a boy
    And child has a general consent
    And the child has Consent to collect genetic material
    And the child has Consent to collect biospecimens
    And whose next event is
      | event_id         | 010336ad-e50f-4df6-a8ee-f50d1cfb1a62 |
      | event_type       | Pregnancy Visit 2                    |
      | event_start_date | 2013-08-11                           |

  Scenario: The appointment sheet contains the participant's contact information
    Given an authenticated user
    When I view the appointment sheet for "Dawn Davidson"
    Then I should see scheduled event "Pregnancy Visit 1"
    Then I should see the event date of "04/08/2013" and start time of "2:45 PM"
    Then I should see the address of "123 73rd Ave.", "Apt. 1C", "Rockville, Maryland"
    Then I should see the cell phone number "444-342-3654" and home phone number of "301-908-1212"
    Then I should see the participant's name, "Dawn Davidson", and public id, "abc-123-wxyz"
    Then I should see that see speaks "English"
    Then I should see that she has consent of "Biological"
    Then I should see that she has consent of "Environmental"
    Then I should see that she has a child named "Harley Davidson"
    Then I should see that he is a "Male"
    Then I should see his age is "8 months old"
    Then I should see the child has consent of "Biological"
    Then I should see the child has consent of "Genetic"
    Then I should see the the "Pregnancy Visit 1 SAQ" as to be conducted
    Then I should see the the "Biospecimen Adult Blood Instrument" as to be conducted
    Then I should see the the "Biospecimen Adult Urine Instrument" as to be conducted
    Then I should see the the "Environmental Tap Water Pesticides Technician Collect Instrument" as to be conducted
    Then I should see the the "Environmental Tap Water TWQ Participant Collect SAQ Specification" as to be conducted
    Then I should see the the "Environmental Tap Water Pharmaceuticals Technician Collect Instrument" as to be conducted
    Then I should see the the "Environmental Vacuum Bag Dust Technician Collect Instrument" as to be conducted
    Then I should see the the "Environmental Vacuum Bag Dust (VBD) Participant Collect SAQ Specification" as to be conducted
    Then I should see the the "Environmental Sample Kit Distribution Instrument" as to be conducted
    Then I should see the the "Environmental Sample Kit Distribution Instrument" as to be conducted
    Then I should see the the "Tracing Module" as to be conducted
    Then I should see the the "Birth Visit Information Sheet" as to be conducted
    Then I should see the the "Pregnancy Visit 1 Information Sheet" as to be conducted
    Then I should see the the "Pregnancy Health Care Log" as to be conducted
    Then I should the next event as "Pregnancy Visit 2"

