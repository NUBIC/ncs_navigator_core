# -*- coding: utf-8 -*-

module PeopleHelper

  def unique_contact_mode_entries(contact_mode_entries)
    filter_criteria = contact_mode_entries.first.filter_criteria
    contact_mode_entries.uniq_by(&filter_criteria)
  end

  def highest_ranking_contact_mode_entry(contact_mode_entries)
    highest_ranking = []
    type_code = contact_mode_entries.first.type_code
    rank_code = contact_mode_entries.first.rank_code
    gt = lambda { |new_rank, old_rank| ranks = [1, 2, -5, 4, -4]; ranks.index(new_rank) < ranks.index(old_rank) }
    highest_ranking_hash = contact_mode_entries.each_with_object({}) { |entries, h| c = h[entries.send(type_code)]; h[entries.send(type_code)] = entries if !c || gt[entries.send(rank_code), c.send(rank_code)] }
    highest_ranking_hash.each_value { |entry| highest_ranking << entry }
    highest_ranking
  end
end
