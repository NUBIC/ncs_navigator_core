@api
Feature: Provider retrieval
  In order to keep field workers abreast of provider data
  The field client application
  Needs to periodically check in for new providers.

  Background:
    Given there exists a provider

  Scenario: GET /api/v1/providers requires authentication
    When I GET /api/v1/providers with headers
      | X-Client-ID | foo |

    Then the response status is 401

  Scenario: GET /api/v1/providers requires an X-Client-ID header
    Given an authenticated user

    When I GET /api/v1/providers

    Then the response status is 400

  Scenario: GET /api/v1/providers checks If-Modified-Since
    Given an authenticated user
    And the providers were last modified on "01/01/2000 00:00:00 GMT"

    When I GET /api/v1/providers with headers
      | X-Client-ID        | foo                           |
      | If-Modified-Since  | Mon, 01 Oct 2012 00:00:00 GMT |

    Then the response status is 304

  Scenario: GET /api/v1/providers returns all providers
    Given an authenticated user

    When I GET /api/v1/providers with headers
      | X-Client-ID        | foo |

    Then the response status is 200
    And the response body contains providers
    And the response body satisfies the providers schema
