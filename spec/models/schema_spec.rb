require 'spec_helper'

describe 'The schema' do
  it 'uses only the integer data type for all NcsCode attributes' do
    non_integer_code_columns = ActiveRecord::Base.connection.select_all(<<-SQL)
      SELECT table_name, column_name, data_type
      FROM information_schema.columns
      WHERE column_name LIKE '%_code' AND data_type <> 'integer' AND table_schema = 'public'
        -- Surveyor models do not obey the same conventions
        AND table_name <> 'surveys'
        AND table_name <> 'response_sets'
    SQL

    non_integer_code_columns.should == []
  end
end
