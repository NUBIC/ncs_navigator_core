# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ncs_codes
#
#  created_at   :datetime
#  display_text :string(255)
#  id           :integer          not null, primary key
#  list_name    :string(255)
#  local_code   :integer
#  updated_at   :datetime
#

class NcsCode < ActiveRecord::Base

  validates_presence_of :list_name, :display_text, :local_code

  YES = 1
  NO  = 2
  MISSING_IN_ERROR = -4
  OTHER = -5
  UNKNOWN = -6

  ##
  # Given a list of attributes, returns all NCS codes for those attributes.
  # You can use either symbols or strings for the attributes.  Attributes that
  # do not correspond to an NCS code list will be ignored.
  #
  # The returned object responds to #where, #each (and all other Enumerable
  # methods), and contains some additional helpers for e.g. accessing a subset
  # of returned NCS codes by list name.  See {NcsCodeCollection} for more
  # details.
  #
  # Example
  # =======
  #
  #     NcsCode.for_attributes('who_refused_code', 'perm_closure_code')
  #
  #     # => [#<NcsCode ...>, ...]
  def self.for_attributes(*attrs)
    query = where(:list_name => attrs.map { |c| attribute_lookup(c) }.compact)

    NcsCodeCollection.new(query)
  end

  def self.last_modified
    maximum(:updated_at)
  end

  def self.ncs_code_lookup(attribute_name, options={})
    show_missing_in_error =
      case options
      when true
        options = {}
        true
      else
        options[:include_missing_in_error]
      end

    list_name = attribute_lookup(attribute_name, options)
    codes = for_list_name(list_name)

    unless show_missing_in_error
      codes = codes.reject { |ncs_code| ncs_code.local_code == MISSING_IN_ERROR }
    end

    list = codes.map { |n| [n.display_text, n.local_code] }
    sort_list(list, list_name)
  end

  def self.sort_list(list, list_name)
    positives = list.select{ |pos| pos[1] >= 0 }
    negatives = list.select{ |neg| neg[1] < 0 }

    sk = sort_key(list_name)
    positives.sort { |a, b| a[sk] <=> b[sk] } + negatives.sort { |a, b| a[sk] <=> b[sk] }
  end

  def self.sort_key(list_name)
    codelists_keep_default_order = ['LANGUAGE_' ,'CONFIRM_', 'RANGE_']
    keep_default_order = false
    codelists_keep_default_order.each { |cl| keep_default_order = true if list_name.to_s.include?(cl) }
    keep_default_order ? 1 : 0
  end

  ##
  # Return the code list for the given NcsCodedAttribute attribute name.
  #
  # E.g., `NcsCode.attribute_lookup('psu_code') # => 'PSU_CL1'`.
  #
  # Note: this method uses a dynamically-built index which is created the first
  # time it is accessed in a process. If you are dynamically creating models,
  # you'll want to create them all before calling this method, or you'll need
  # to purge the index (see {.clear_attribute_lookup_index}).
  #
  # @param [#to_s] attribute_name the attribute for which the list is
  #   desired.
  # @param [Hash] options values to influence the lookup.
  # @option options [String,nil] :mdes_version (application version) the MDES
  #   version for which to return the list.
  # @option options [#to_s,nil] :model_class in the rare case where the same
  #   attribute appears in multiple models with different code lists, specifying
  #   the model allows you specify which attribute you mean.
  def self.attribute_lookup(attribute_name, options={})
    mdes_version = options[:mdes_version] || NcsNavigatorCore.mdes_version.number
    model = options[:model_class].try(:to_s)

    matches = attribute_lookup_index(mdes_version)[attribute_name.to_s]
    if matches.nil?
      nil
    elsif matches.size == 1
      matches.keys.first
    else
      list_name, _ = matches.find { |list_name, models| models.include?(model) }
      if list_name
        list_name
      elsif model
        fail "#{model}##{attribute_name} is not a coded attribute (it may not be an attribute at all)"
      else
        fail "#{attribute_name} maps to #{matches.size} code lists in different models. Please use :model_class => 'Foo' to disambiguate."
      end
    end
  end

  class << self
    def attribute_lookup_index(mdes_version)
      @attribute_lookup_index ||= {}
      @attribute_lookup_index[mdes_version] ||= build_attribute_lookup_index(mdes_version)
    end
    private :attribute_lookup_index

    def build_attribute_lookup_index(mdes_version)
      all_coded_attributes = NcsNavigator::Core::Mdes::MdesRecord.models.
        collect { |rec| rec.ncs_coded_attributes.values }.flatten
      all_coded_attributes.each_with_object({}) do |nca, index|
        attribute_entry = (index[nca.foreign_key_name.to_s] ||= {})
        (attribute_entry[nca.list_name(mdes_version)] ||= []) << nca.model_class.to_s
      end
    end
    private :build_attribute_lookup_index

    def clear_attribute_lookup_index
      @attribute_lookup_index = nil
    end
  end

  def self.for_attribute_name_and_local_code(attribute_name, local_code, attribute_lookup_options={})
    for_list_name_and_local_code(
      attribute_lookup(attribute_name, attribute_lookup_options), local_code)
  end

  def self.for_list_name(list_name)
    Rails.application.code_list_cache.code_list(list_name)
  end

  def self.for_list_name_and_local_code(list_name, local_code)
    Rails.application.code_list_cache.code_value(list_name, local_code.to_i)
  end

  def self.for_list_name_and_display_text(list_name, display_text)
    cl = for_list_name(list_name)
    return nil unless cl
    cl.find { |ncs_code| ncs_code.display_text == display_text }
  end

  def self.find_event_by_lbl(lbl)
    EventLabel.new(lbl).ncs_code
  end

  # Special case helper method to get EVENT_TYPE_CL1 for Low Intensity Data Collection
  # Used to determine if participant is eligible for conversion to High Intensity Arm
  def self.low_intensity_data_collection
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.low_intensity_data_collection_code)
  end

  def self.low_intensity_pregnancy_visit
    # Pregnancy Visit - Low Intensity Group
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_low_intensity_group_code)
  end

  # Special case helper method to get EVENT_TYPE_CL1 for Pregnancy Screener
  # Used to determine if participant should be screened
  def self.pregnancy_screener
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_screener_code)
  end

  # Special case helper method to get EVENT_TYPE_CL1 for PBS Eligibility Screener
  # Used to determine if participant should be screened
  def self.pbs_eligibility_screener
    for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pbs_eligibility_screener_code)
  end

  ##
  # Override to reset cache when called. Should only be used in tests.
  def self.create!(*args)
    Rails.application.code_list_cache.reset
    super
  end

  def to_s
    display_text
  end

  def to_i
    local_code
  end

  def code
    local_code
  end

  def ==(comparison_object)
    comparison_object.equal?(self) ||
      (comparison_object.instance_of?(self.class) &&
      comparison_object.list_name == self.list_name &&
      comparison_object.local_code == self.local_code)
  end
end
