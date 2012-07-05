# -*- coding: utf-8 -*-
##
# Updates latest merge statuses on fieldwork sets.  The cached status strings
# are used to accelerate reporting.
#
# Given a fieldwork set with merges M1, ..., Mn, the latest merge status is the
# status of the merge that completed last.  For bookkeeping convenience, the ID
# of the latest completed merge is also copied to the fieldwork set.
class MergeObserver < ActiveRecord::Observer
  def after_save(merge)
    fw = Fieldwork.find(merge.fieldwork_id)

    return unless fw

    # Don't execute during migrations
    return unless fw.respond_to?(:latest_merge_status)

    fw.latest_merge_status = merge.status
    fw.latest_merge_id = merge.id
    fw.save(:validate => false)
  end
end
