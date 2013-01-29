class IndexSurveyTitles < ActiveRecord::Migration
  def up
    add_index :surveys, :title
  end

  def down
    remove_index :surveys, :column => :title
  end
end
