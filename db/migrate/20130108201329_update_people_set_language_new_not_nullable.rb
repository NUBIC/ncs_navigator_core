class UpdatePeopleSetLanguageNewNotNullable < ActiveRecord::Migration
  def up
    change_column_null(:people, :language_new_code, false, -4)
  end

  def down
    change_column_null(:people, :language_new_code, true)
  end
end
