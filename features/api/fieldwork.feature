@wip @api
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

    Then the response status is 201

  Scenario: PUT /api/v1/fieldwork/:uuid creates pending merge sets
    Given an authenticated user

    When I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {
        "contacts": [],
        "participants": []
    }
    """
    And I GET the referenced location

    Then the response status is 200
    And the response body satisfies
      | key       | value     |
      | status    | pending   |
      | submitter | test_user |

  Scenario: PUT /api/v1/fieldwork/:uuid returns 401 to unauthorized requests
    When I PUT /api/v1/fieldwork/cf651bcf-ca1d-45ec-87c7-38cb995271df with
    """
    {
        "contacts": [],
        "participants": []
    }
    """

    Then the response status is 401
