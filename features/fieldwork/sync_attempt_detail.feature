@merge
Feature: Detail view of a sync attempt
  In order to ensure field clients' data is synced with Core
  Site administrators
  Need a way to list and show sync attempts.

  Background:
    Given an authenticated user
    And the sync attempts
      | id  | status   |
      | foo | conflict |

  Scenario: The detail view shows the conflict report
    Given merging "foo" caused conflicts
      | entity         | attribute | original | current | proposed |
      | Contact abcdef | language  | 0        | 1       | 2        |

    When I go to the sync attempt page for "foo"

    Then I see the conflict report
      | entity         | attribute | original | current | proposed |
      | Contact abcdef | Language  | 0        | 1       | 2        |

  Scenario: NCS coded attributes are resolved
    Given merging "foo" caused conflicts
      | entity         | attribute             | original | current | proposed |
      | Contact abcdef | contact_language_code | -4       | 1       | 2        |

    When I go to the sync attempt page for "foo"

    Then I see the conflict report
      | entity         | attribute             | original         | current | proposed |
      | Contact abcdef | Contact language code | Missing in Error | English | Spanish  |
