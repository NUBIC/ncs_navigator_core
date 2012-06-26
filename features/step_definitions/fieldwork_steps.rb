Given /^the sync attempts$/ do |table|
  table.hashes.each do |sync|
    id = sync['id']
    status = sync['status']

    steps %Q{
      When I PUT /api/v1/fieldwork/#{id} with
      """
      {}
      """
      Then the response status is 202
    }

    # Munge status.
    fw = Fieldwork.find_by_fieldwork_id(id)
    fw.update_attribute(:latest_merge_status, status)
  end
end

Then /^I see the sync attempts$/ do |table|
  ids = all('.sync_attempt .fieldwork_id').map(&:text).map(&:strip)
  statuses = all('.sync_attempt .status').map(&:text).map(&:strip)
  actual = [['id', 'status']] + ids.zip(statuses)

  table.diff!(actual)
end
