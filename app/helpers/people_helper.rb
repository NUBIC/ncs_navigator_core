# -*- coding: utf-8 -*-

module PeopleHelper

  # TODO: later on, these orders should probably live in a model or not at all in code
  # union of {ADDRESS,EMAIL,PHONE}_TYPE
  TYPE_ORDER = [1, 2, 3, 4, 5, -5, -6, -4, -1]
  # (1)primary, (2)secondary, (-5)other, (4)duplicate, (3)Invalid, (-4) missing in error
  RANK_ORDER = [1, 2, -5, 4, 3, -4]

  # @param cme
  def group_cme(cme)
    return {} if cme == nil || cme.first == nil
    type_code = cme.first.type_code
    
    out = Hash.new
    TYPE_ORDER.each {|t| out[t]=[]}

    cme.each do |e|
      out[e.send(type_code)] = [] unless out.has_key?(e.send(type_code))
      out[e.send(type_code)] << e
    end
    out.delete_if{|k,v| v==[]}
  end
  

  # @param cme hash of array of Addresses, Phones or Emails or anyting that implements
  #        rank_code and type_code
  # @return hash of rank sorted contact arrays
  def sort_cme(cme)
    return {} if cme == nil
    cme.delete_if {|k,v| v == [] || v==nil}
    return {} if cme.empty?
    
    rank_code = cme[cme.keys.first].first.rank_code
    
    cme.each_value do |type|
      type.sort!{|a,b| RANK_ORDER.index(a.send(rank_code))<=>RANK_ORDER.index(b.send(rank_code))}
    end
  end

end


