# -*- coding: utf-8 -*-

module PeopleHelper

  # @note This removes addresses with the same :address_one, possibly in error
  def unique_contact_mode_entries(contact_mode_entries)
    return [] if contact_mode_entries == nil || contact_mode_entries.first == nil
    filter_criteria = contact_mode_entries.first.filter_criteria if !contact_mode_entries.first.nil?
    contact_mode_entries.uniq_by(&filter_criteria)
  end

  def highest_ranking_contact_mode_entry(contact_mode_entries)
    return [] if contact_mode_entries == nil || contact_mode_entries.first == nil
    highest_ranking = []
    type_code = contact_mode_entries.first.type_code if !contact_mode_entries.first.nil?
    rank_code = contact_mode_entries.first.rank_code if !contact_mode_entries.first.nil?
    gt = lambda { |new_rank, old_rank| ranks = [1, 2, -5, 4, -4]; ranks.index(new_rank).to_i < ranks.index(old_rank).to_i }
    highest_ranking_hash = contact_mode_entries.each_with_object({}) { |entries, h| c = h[entries.send(type_code)]; h[entries.send(type_code)] = entries if !c || gt[entries.send(rank_code), c.send(rank_code)] }
    highest_ranking_hash.each_value { |entry| highest_ranking << entry }
    highest_ranking
  end
  
  # ranks sorted by (1)primary, (2)secondary, (-5)other, (4)duplicate, (3)Invalid, (-4) missing in error
  # @return type-sorted hash of non-empty rank-sorted contact arrays.
  def sort_contact_mode_entries(contact_mode_entries)
    return [] if contact_mode_entries == nil || contact_mode_entries.first == nil
    type_code = contact_mode_entries.first.type_code if !contact_mode_entries.first.nil?
    rank_code = contact_mode_entries.first.rank_code if !contact_mode_entries.first.nil?
    ranks = [1, 2, -5, 4, 3, -4]
    out = {1=>[], 2=>[], 3=>[], 4=>[], 5=>[], -5=>[], -6=>[], -4=>[]}
    
    contact_mode_entries.each {|e| out[e.send(type_code)] << e}
    out.delete_if {|k,v| v == []}
    #should add secondary sort by created/updated time
    out.each_value do |type| 
      type.sort!{|a,b| ranks.index(a.send(rank_code))<=>ranks.index(b.send(rank_code))}
    end
    out
  end
  
end


