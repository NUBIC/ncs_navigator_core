@api
Feature: Event reporting
	In order to schedule work across a ROC
	Staff supervisors
	Want to summarize work being done at a Cases location.

  Scenario: GET /api/v1/events requires authentication
    When I GET /api/v1/events with
      | header:X-Client-ID | foo |

    Then the response status is 401

  Scenario: GET /api/v1/events requires an X-Client-ID header
    Given an authenticated user

    When I GET /api/v1/events

    Then the response status is 400

  Scenario: GET /api/v1/events requires at least one filter
    Given an authenticated user

    When I GET /api/v1/events with
      | header:X-Client-ID | foo |

    Then the response status is 400
