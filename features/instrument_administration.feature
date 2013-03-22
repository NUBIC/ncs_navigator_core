Feature: Instrument administration
  As an NCS staff member
  In order to speed up data entry
  I want to be able to administer instruments directly in Cases
  instead of doing instruments on paper and copying it into Cases.

  Background:
    Given I log in as "staff_user"

  Scenario: Mustache helpers in surveys are frozen in time
    Given the child
      | first_name | Foobar |
      | mother     | Mom    |
    And "Mom" has pending work in Cases
    And the survey
    """
    survey "test_survey", :instrument_type => -4, :instrument_version => '1' do
      section "A section" do
        q_helper_c_fname "q_helper_c_fname", :display_type => :hidden, :custom_class => 'helper'
        a 'value', :string

        q_weight "How much does {{c_fname}} weigh?"
        a :integer
      end
    end
    """

    When I administer "test_survey" to "Foobar" via "Mom"
    Then I should see "How much does Foobar weigh?"

    When I change "Foobar"'s first name to "Foobaz"
    And I edit "Mom"'s responses for "test_survey"
    Then I should see "How much does Foobar weigh?"
