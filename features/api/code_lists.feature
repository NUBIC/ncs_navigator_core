@api @mdes @tmpdir
Feature: Code lists retrieval
  In order to keep field workers abreast of MDES changes
  The field client application
  Needs to periodically check in for new NCS codes.

  Scenario: GET /api/v1/code_lists requires authentication
    When I GET /api/v1/code_lists with
      | header:X-Client-ID | foo |

    Then the response status is 401

  Scenario: GET /api/v1/code_lists requires an X-Client-ID header
    Given an authenticated user

    When I GET /api/v1/code_lists

    Then the response status is 400

  Scenario: GET /api/v1/code_lists checks If-Modified-Since
    Given an authenticated user
    And the NCS codes were last modified on "01/01/2000 00:00:00 GMT"
    And the MDES disposition codes were last modified on "01/01/2000 00:00:00 GMT"

    When I GET /api/v1/code_lists with
      | header:X-Client-ID       | foo                           |
      | header:If-Modified-Since | Mon, 01 Oct 2012 00:00:00 GMT |

    Then the response status is 304

  Scenario: GET /api/v1/code_lists satisfies its schema
    Given an authenticated user

    When I GET /api/v1/code_lists with
      | header:X-Client-ID | foo |

    Then the response status is 200
    And the response body satisfies the code lists schema

  Scenario: GET /api/v1/code_lists returns MDES version information
    Given an authenticated user

    When I GET /api/v1/code_lists with
      | header:X-Client-ID | foo |

    Then the response status is 200
    And the response body contains the MDES version
    And the response body contains the MDES specification version

  Scenario: GET /api/v1/code_lists returns all NCS codes
    Given an authenticated user

    When I GET /api/v1/code_lists with
      | header:X-Client-ID | foo |

    And the response body contains NCS codes

  Scenario: GET /api/v1/code_lists returns all MDES disposition codes
    Given an authenticated user

    When I GET /api/v1/code_lists with
      | header:X-Client-ID | foo |

    Then the response status is 200
    And the response body contains MDES disposition codes
