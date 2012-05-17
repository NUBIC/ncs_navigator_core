@api
Feature: Fieldwork check-out and check-in
  In order to keep field workers abreast of study progress
  The field client application
  Needs to check out and check in work done by those workers.

  Scenario: PUT /api/v1/fieldwork/:uuid accepts data from clients
    Given an authenticated user

    When I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {
        "contacts": [],
        "participants": []
    }
    """

    Then the response status is 202

  Scenario: PUT /api/v1/fieldwork/:uuid requires authentication
    When I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {
        "contacts": [],
        "participants": []
    }
    """

    Then the response status is 401

  Scenario: GET /api/v1/fieldwork/:uuid returns the latest PUT
    Given an authenticated user
    And I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {}
    """
    And I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
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

    When I GET /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df

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
    And I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {}
    """

    When I GET the referenced location

    Then the response status is 200
    And the response body matches
    """
    { "status": "pending" }
    """

  Scenario: POST /api/v1/fieldwork requires authentication
    When I POST /api/v1/fieldwork with
      | start_date | end_date   | client_id |
      | 2012-01-01 | 2012-02-01 | 123456789 |

    Then the response status is 401

  @wip
  Scenario: POST /api/v1/fieldwork builds contacts for the given date range
    Given an authenticated user

    When I POST /api/v1/fieldwork with
      | start_date | end_date   | client_id |
      | 2012-02-01 | 2012-03-01 | 123456789 |

    Then the response status is 200
    And the response is a fieldwork set
    And the response contains a reference to itself
    And the response body matches
    """
    {
        "contacts": [
            {
                "person_id": "b9696270-3586-012f-ca18-58b035fb69ca",
                "start_date": "2012-02-16T00:00:00Z"
            },
            {
                "person_id": "f76a39d0-34d2-012f-c14a-58b035fb69ca",
                "start_date": "2012-02-08T00:00:00Z"
            },
            {
                "person_id": "f76a39d0-34d2-012f-c14a-58b035fb69ca",
                "start_date": "2012-02-08T00:00:00Z"
            },
            {
                "person_id": "98463040-3321-012f-8aa6-58b035fb69ca",
                "start_date": "2012-02-13T00:00:00Z"
            },
            {
                "person_id": "b0b39b70-38be-012f-11d5-58b035fb69ca",
                "start_date": "2012-02-17T00:00:00Z"
            },
            {
                "person_id": "b0b39b70-38be-012f-11d5-58b035fb69ca",
                "start_date": "2012-02-17T00:00:00Z"
            }
        ]
    }
    """

  Scenario: POST /api/v1/fieldwork requires start_date, end_date, and client_id
    Given an authenticated user

    When I POST /api/v1/fieldwork with
      | end_date   | client_id |
      | 2012-02-01 | 123456789 |
    Then the response status is 400

    When I POST /api/v1/fieldwork with
      | start_date | client_id |
      | 2012-02-01 | 123456789 |
    Then the response status is 400

    When I POST /api/v1/fieldwork with
      | end_date   | start_date |
      | 2012-01-01 | 2012-02-01 |
    Then the response status is 400
