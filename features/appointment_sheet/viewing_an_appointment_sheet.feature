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
    And whose due date is "2012-09-12"
    And has a last contact comment of "Watch out for the big dog!"
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
    And I see scheduled event "Pregnancy Visit 1"
    And I see the event date of "04/08/2013" and start time of "2:45 PM"
    And I see the address of "123 73rd Ave.", "Apt. 1C", "Rockville, Maryland"
    And I see the cell phone number "444-342-3654" and home phone number of "301-908-1212"
    And I see the participant's name, "Dawn Davidson", and public id, "abc-123-wxyz"
    And I see that see speaks "English"
    And I see that she has consent of "Biological"
    And I see that she has consent of "Environmental"
    And I see that she has a child named "Harley Davidson"
    And I see "Birth date: 08/12/2012"
    And I see "Due date: 09/12/2012"
    And I see that he is a "Male"
    And I see his age is "8 months old"
    And I see the child has consent of "Biological"
    And I see the child has consent of "Genetic"
    And I see the last comment was "Watch out for the big dog!"
    And I see the "Pregnancy Visit 1 SAQ" as to be conducted
    And I see the "Biospecimen Adult Blood Instrument" as to be conducted
    And I see the "Biospecimen Adult Urine Instrument" as to be conducted
    And I see the "Environmental Tap Water Pesticides Technician Collect Instrument" as to be conducted
    And I see the "Environmental Tap Water TWQ Participant Collect SAQ Specification" as to be conducted
    And I see the "Environmental Tap Water Pharmaceuticals Technician Collect Instrument" as to be conducted
    And I see the "Environmental Vacuum Bag Dust Technician Collect Instrument" as to be conducted
    And I see the "Environmental Vacuum Bag Dust (VBD) Participant Collect SAQ Specification" as to be conducted
    And I see the "Environmental Sample Kit Distribution Instrument" as to be conducted
    And I see the "Environmental Sample Kit Distribution Instrument" as to be conducted
    And I see the "Tracing Module" as to be conducted
    And I see the "Birth Visit Information Sheet" as to be conducted
    And I see the "Pregnancy Visit 1 Information Sheet" as to be conducted
    And I see the "Pregnancy Health Care Log" as to be conducted
    And I see the next event as "Pregnancy Visit 2"

