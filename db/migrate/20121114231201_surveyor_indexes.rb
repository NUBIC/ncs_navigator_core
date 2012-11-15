class SurveyorIndexes < ActiveRecord::Migration
  NEEDED_INDEXES = {
    'surveys'               => %w(display_order),
    'survey_sections'       => %w(display_order),
    'questions'             => %w(survey_section_id question_group_id display_order reference_identifier),
    'answers'               => %w(question_id display_order reference_identifier),
    'dependencies'          => %w(question_id question_group_id),
    'dependency_conditions' => %w(dependency_id question_id answer_id),
    'response_sets'         => %w(survey_id user_id instrument_id participant_id),
    'responses'             => %w(response_set_id question_id answer_id)
  }

  def up
    NEEDED_INDEXES.each do |table, columns|
      columns.each do |column|
        add_index(table, column, :unique => false, :name => index_name(table, column))
      end
    end
  end

  def down
    NEEDED_INDEXES.each do |table, columns|
      columns.each do |column|
        remove_index(table, :name => index_name(table, column))
      end
    end
  end

  private

  def index_name(table, column)
    "idx_#{table}_#{column}"
  end
end
