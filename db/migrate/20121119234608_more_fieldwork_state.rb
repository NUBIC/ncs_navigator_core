class MoreFieldworkState < ActiveRecord::Migration
  def up
    add_column :fieldworks, :contact_links, :text
    add_column :fieldworks, :contacts, :text
    add_column :fieldworks, :event_templates, :text
    add_column :fieldworks, :events, :text
    add_column :fieldworks, :generated_for, :string
    add_column :fieldworks, :instrument_plans, :text
    add_column :fieldworks, :instruments, :text
    add_column :fieldworks, :people, :text
    add_column :fieldworks, :surveys, :text
  end

  def down
    remove_column :fieldworks, :surveys
    remove_column :fieldworks, :people
    remove_column :fieldworks, :instruments
    remove_column :fieldworks, :instrument_plans
    remove_column :fieldworks, :generated_for
    remove_column :fieldworks, :events
    remove_column :fieldworks, :event_templates
    remove_column :fieldworks, :contacts
    remove_column :fieldworks, :contact_links
  end
end
