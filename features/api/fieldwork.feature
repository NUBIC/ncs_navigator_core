@api
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

    Then the response status is 202

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
