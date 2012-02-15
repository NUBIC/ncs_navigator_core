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

  Scenario: GET /api/v1/fieldwork/:uuid returns what was previously PUT
    Given an authenticated user
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

    When I GET the referenced location

    Then the response status is 200
    And the response body is
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

  Scenario: POST /api/v1/fieldwork requires authentication
    When I POST /api/v1/fieldwork with
      | start_date | end_date   | client_id |
      | 2012-01-01 | 2012-02-01 | 123456789 |

    Then the response status is 401
