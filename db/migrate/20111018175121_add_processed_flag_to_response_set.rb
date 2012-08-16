# -*- coding: utf-8 -*-


class AddProcessedFlagToResponseSet < ActiveRecord::Migration
  def up
    add_column :response_sets, :processed_for_operational_data_extraction, :boolean
  end

  def down
    # Removed from a later migration - AddResponseSetToOperationalData
    # remove_column :response_sets, :processed_for_operational_data_extraction
  end
end