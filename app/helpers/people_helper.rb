# -*- coding: utf-8 -*-

module PeopleHelper
  # @param contact_mode_entries array of Addresses, Phones or Emails or anyting that implements
  #        rank_code and type_code
  # @note ranks sorted by (1)primary, (2)secondary, (-5)other, (4)duplicate, (3)Invalid, (-4) missing in error
  # @note might want to sort by creation time after rank
  # @return type-sorted hash of non-empty rank-sorted contact arrays.
  def sort_contact_mode_entries(contact_mode_entries)
    return {} if contact_mode_entries == nil || contact_mode_entries.first == nil
    type_code = contact_mode_entries.first.type_code
    rank_code = contact_mode_entries.first.rank_code 
    ranks = [1, 2, -5, 4, 3, -4]
    # union of {ADDRESS,EMAIL,PHONE}_TYPE
    out = {1=>[], 2=>[], 3=>[], 4=>[], 5=>[], -5=>[], -6=>[], -4=>[], -1=>[]}    
    
    contact_mode_entries.each do |e| 
      out[e.send(type_code)] = [] unless out.has_key?(e.send(type_code))
      out[e.send(type_code)] << e
    end

    out.delete_if {|k,v| v == []}    
    out.each_value do |type| 
      type.sort!{|a,b| ranks.index(a.send(rank_code))<=>ranks.index(b.send(rank_code))}
    end
    out
  end
  
end


