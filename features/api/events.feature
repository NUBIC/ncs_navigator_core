@api @fieldwork
Feature: Event search API
  Scenario: GET /api/v1/events requires authentication
    When I GET /api/v1/events with
      | header:X-Client-ID | foo |

    Then the response status is 401

  Scenario: GET /api/v1/events requires an X-Client-ID header
    Given an authenticated user

    When I GET /api/v1/events

    Then the response status is 400

  Scenario: GET /api/v1/events with no parameters returns 400
    Given an authenticated user

    When I GET /api/v1/events with
      | header:X-Client-ID | foo |

    Then the response status is 400

  Scenario: GET /api/v1/events satisfies its schema
    Given an authenticated user

    When I GET /api/v1/events with
      | header:X-Client-ID | foo |
      | types[]            | 10  |

    Then the response status is 200
    And the response body satisfies the event search schema

  Scenario: GET /api/v1/events returns 403 for users with no NCS roles
    Given I log in as "no_roles"

    When I GET /api/v1/events with
      | header:X-Client-ID | foo |
      | types[]            | 10  |

    Then the response status is 403

  Scenario: GET /api/v1/events returns 403 for users not in the correct portal
    Given I log in as "no_portal"

    When I GET /api/v1/events with
      | header:X-Client-ID | foo |
      | types[]            | 10  |

    Then the response status is 403
