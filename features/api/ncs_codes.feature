@api
Feature: NCS code retrieval
  In order to keep field workers abreast of MDES changes
  The field client application
  Needs to periodically check in for new NCS codes.

  Scenario: GET /api/v1/ncs_codes requires authentication
    When I GET /api/v1/ncs_codes with headers
      | X-Client-ID | foo |

    Then the response status is 401

  Scenario: GET /api/v1/ncs_codes requires an X-Client-ID header
    Given an authenticated user

    When I GET /api/v1/ncs_codes

    Then the response status is 400

  Scenario: GET /api/v1/ncs_codes checks If-Modified-Since
    Given an authenticated user
    And the NCS codes were last modified on "01/01/2000 00:00:00 GMT"

    When I GET /api/v1/ncs_codes with headers
      | X-Client-ID        | foo                           |
      | If-Modified-Since  | Mon, 01 Oct 2012 00:00:00 GMT |

    Then the response status is 304

  Scenario: GET /api/v1/ncs_codes returns all NCS codes
    Given an authenticated user

    When I GET /api/v1/ncs_codes with headers
      | X-Client-ID | foo |

    Then the response status is 200
    And the response body contains the MDES version
    And the response body contains the MDES specification version
    And the response body contains NCS codes
