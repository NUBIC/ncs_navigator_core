@api @fieldwork
Feature: Fieldwork check-out and check-in
  In order to keep field workers abreast of study progress
  The field client application
  Needs to check out and check in work done by those workers.

  Scenario: PUT /api/v1/fieldwork/:uuid accepts data from clients
    Given an authenticated user

    When the payload is
    """
    {
        "contacts": [],
        "participants": []
    }
    """
    And I PUT the payload to /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
      | header:X-Client-ID | 1234567890 |

    Then the response status is 204

  Scenario: PUT /api/v1/fieldwork/:uuid requires authentication
    Given the payload
    """
    {
        "contacts": [],
        "participants": []
    }
    """

    When I PUT the payload to /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
      | header:X-Client-ID | 1234567890 |

    Then the response status is 401

  Scenario: GET /api/v1/fieldwork/:uuid returns the latest PUT
    Given an authenticated user
    And a fieldwork packet for "cf651bcf-ca1d-45ec-87c7-38cb995271df"

    When the payload is
    """
    {
        "contacts": [
            {
                "contact_id": "93ac2b20-2a7b-426c-891f-3c4754139a12"
            }
        ],
        "participants": []
    }
    """
    And I PUT the payload to /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
      | header:X-Client-ID | 1234567890 |
    And I GET /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df

    Then the response status is 200
    And the response body matches
    """
    {
        "contacts": [
            {
                "contact_id": "93ac2b20-2a7b-426c-891f-3c4754139a12"
            }
        ],
        "participants": []
    }
    """

  Scenario: PUT /api/v1/fieldwork/:uuid returns a URL to check the merge
    Given an authenticated user

    When the payload is
    """
    {}
    """
    And I PUT the payload to /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
      | header:X-Client-ID | 1234567890 |
    And I GET the referenced location

    Then the response status is 200
    And the response body matches
    """
    { "status": "pending" }
    """

  Scenario: PUT /api/v1/fieldwork/:uuid requires a client ID
    Given an authenticated user
    And the payload
    """
    {}
    """
    When I PUT the payload to /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df

    Then the response status is 400

  Scenario: POST /api/v1/fieldwork returns a fieldwork set
    Given an authenticated user

    When I POST /api/v1/fieldwork with
      | start_date         | 2005-07-01 |
      | end_date           | 2005-07-30 |
      | header:X-Client-ID | 1234567890 |

    Then the response status is 201
    And the response body satisfies the fieldwork schema

  Scenario: POST /api/v1/fieldwork requires authentication
    When I POST /api/v1/fieldwork with
      | start_date         | 2012-01-01 |
      | end_date           | 2012-02-01 |
      | header:X-Client-ID | 1234567890 |

    Then the response status is 401

  Scenario: POST /api/v1/fieldwork requires start_date, end_date, and client_id
    Given an authenticated user

    When I POST /api/v1/fieldwork with
      | start_date | 2012-01-01 |
      | end_date   | 2012-02-01 |
    Then the response status is 400

    When I POST /api/v1/fieldwork with
      | start_date         | 2012-01-01 |
      | header:X-Client-ID | 1234567890 |
    Then the response status is 400

    When I POST /api/v1/fieldwork with
      | end_date           | 2012-01-01 |
      | header:X-Client-ID | 1234567890 |
    Then the response status is 400

  Scenario: POST /api/v1/fieldwork returns instruments in template-prescribed order
    This scenario relies on data in
    features/fixtures/fakeweb/scheduled_activities_2013-01-01.json; refer to
    the Pregnancy Probability events in that file for more information.

    Given an authenticated user
    And the participant
      | person/first_name | Betty               |
      | person/last_name  | Boop                |
      | person/person_id  | registered_with_psc |
    And the event
      | event_id         | ce998f48-5775-4a23-86f9-4c2562f69318 |
      | event_type       | Pregnancy Probability                |
      | event_start_date | 2013-01-01                           |
    And the surveys
      | instrument_version | title                                  |
      | 1.2                | ins_que_ppgfollup_int_ehpbhili_p2_v1.2 |
      | 1.1                | ins_que_ppgfollup_saq_ehpbhili_p2_v1.1 |

    When I POST /api/v1/fieldwork.json with
      | start_date         | 2013-01-01 |
      | end_date           | 2013-01-07 |
      | header:X-Client-ID | 1234567890 |

    Then the response body satisfies
      | /contacts/0/events/0/instruments/0/name | Pregnancy Probability Group Follow-Up SAQ       |
      | /contacts/0/events/0/instruments/1/name | Pregnancy Probability Group Follow-Up Interview |

  Scenario: POST /api/v1/fieldwork returns instruments in template-prescribed order
    This scenario relies on data in
    features/fixtures/fakeweb/scheduled_activities_2013-04-24.json; refer to
    the Birth event in that file for more information.

    Given an authenticated user
    And the participant
      | p_id              | abc-de-fghi         |
      | person/first_name | Aria                |
      | person/last_name  | Appleton            |
      | person/person_id  | registered_with_psc |
    And the event
      | event_id         | f74a5ff2-100b-451e-902c-80ee08873144 |
      | event_type       | Birth                                |
      | event_start_date | 2013-04-24                           |
    And the surveys
      | instrument_version | title                                                  |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_part_one              |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_birth_visit_baby_name |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_part_two              |

    When I POST /api/v1/fieldwork.json with
      | start_date         | 2013-04-24 |
      | end_date           | 2013-05-01 |
      | header:X-Client-ID | 1234567890 |

    Then the response body satisfies
      | /contacts/0/events/0/name | Birth |
      | /contacts/0/events/0/instruments/0/response_sets/0/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/1/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/2/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/0/p_id | abc-de-fghi |
      | /contacts/0/events/0/instruments/0/response_sets/2/p_id | abc-de-fghi |
    And the response body has "2" distinct values for "p_id" at "/contacts/0/events/0/instruments/0/response_sets"
      
  Scenario: POST /api/v1/fieldwork returns instruments in template-prescribed order
    This scenario relies on data in
    features/fixtures/fakeweb/scheduled_activities_2013-04-24.json; refer to
    the Birth event in that file for more information. This is for when the
    child exists.

    Given an authenticated user
    And the participant
      | p_id              | jkl-mn-opqr           |
      | person/first_name | Baby                  |
      | person/last_name  | Appleton              |
      | person/person_id  | registered_with_psc_2 |
    And the participant
      | p_id              | abc-de-fghi         |
      | person/first_name | Aria                |
      | person/last_name  | Appleton            |
      | person/person_id  | registered_with_psc |
    And the participant person link
      | p_id        | person_id             | relationship_code |
      | abc-de-fghi | registered_with_psc_2 | 8                 |
    And the event
      | event_id         | f74a5ff2-100b-451e-902c-80ee08873144 |
      | event_type       | Birth                                |
      | event_start_date | 2013-04-24                           |
    And the surveys
      | instrument_version | title                                                  |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_part_one              |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_birth_visit_baby_name |
      | 2.0                | ins_que_birth_int_ehpbhi_p2_v2.0_part_two              |

    When I POST /api/v1/fieldwork.json with
      | start_date         | 2013-04-24 |
      | end_date           | 2013-05-01 |
      | header:X-Client-ID | 1234567890 |

    Then the response body satisfies
      | /contacts/0/events/0/name | Birth |
      | /contacts/0/events/0/instruments/0/response_sets/0/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/1/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/2/person_id | registered_with_psc |
      | /contacts/0/events/0/instruments/0/response_sets/0/p_id | abc-de-fghi |
      | /contacts/0/events/0/instruments/0/response_sets/1/p_id | jkl-mn-opqr |
      | /contacts/0/events/0/instruments/0/response_sets/2/p_id | abc-de-fghi |
      