# -*- coding: utf-8 -*-

require 'active_support/concern'
require 'uuidtools'
module MdesRecord
  extend ActiveSupport::Concern

  DEFAULT_DATE_FORMAT = '%Y-%m-%d'

  included do
    before_create :set_public_id
    before_validation :set_missing_in_error
    before_save :format_dates
  end

  module ClassMethods

    def acts_as_mdes_record(options = {})
      send :include, InstanceMethods
      cattr_accessor :public_id_field
      cattr_accessor :date_fields
      self.public_id_field = (options[:public_id_field] || :uuid)
      if options[:date_fields]
        self.date_fields = options[:date_fields]
        options[:date_fields].each do |df|
          attr_accessor "#{df}_modifier"
        end
      end
    end

    def ncs_coded_attribute(attribute_name, list_name)
      ncs_coded_attributes[attribute_name.to_sym] =
        ::MdesRecord::NcsCodedAttribute.new(self, attribute_name, list_name)
    end

    def ncs_coded_attributes
      @ncs_coded_attributes ||= {}
    end

  end

  class NcsCodedAttribute
    attr_reader :attribute_name, :list_name

    def initialize(model_class, attribute_name, list_name)
      @list_name = list_name.upcase
      @attribute_name = attribute_name.to_sym
      belongs_to!(model_class)
    end

    def foreign_key
      @foreign_key ||= "#{attribute_name}_code".to_sym
    end

    def belongs_to!(model)
      model.belongs_to(attribute_name,
        :conditions => "list_name = '#{list_name}'",
        :foreign_key => foreign_key,
        :class_name => 'NcsCode',
        :primary_key => :local_code)
    end
  end

  module InstanceMethods

    def set_public_id
      self.send("#{self.public_id_field}=", UUIDTools::UUID.random_create.to_s) if self.uuid.blank?
    end

    def public_id
      self.send("#{self.public_id_field}")
    end

    def uuid
      if self.public_id_field == :uuid
        super
      else
        self.send("#{self.public_id_field}")
      end
    end

    # If an NCS Code is missing, default the selection to 'Missing in Error' whose local_code value is -4
    def set_missing_in_error
      self.class.reflect_on_all_associations.each do |association|
        if association.options[:class_name] == "NcsCode" && not_set?(association.name.to_sym)
          missing_in_error_code = NcsCode.where("#{association.options[:conditions]} AND local_code = -4").first
          self.send("#{association.name}=", missing_in_error_code)
        end
      end
    end

    def not_set?(method_name)
      self.send(method_name).blank?
    end

    def format_dates
      if self.date_fields
        self.date_fields.each do |df|

          formatter = self.respond_to?("#{df}_formatter") ? self.send("#{df}_formatter") : MdesRecord::DEFAULT_DATE_FORMAT

          dt = self.send("#{df}_date")
          if dt.blank?
            str_dt = self.send("#{df}")
            begin
              self.send("#{df}_date=", Date.parse(str_dt))
            rescue
              # NOOP str_dt is unparseable
            end
          else
            self.send("#{df}=", dt.strftime(formatter))
          end

          mod = self.send("#{df}_modifier")

          unless mod.blank?
            case mod
            when 'refused'
              self.send("#{df}=", missing_date(formatter, "1"))
            when 'unknown'
              self.send("#{df}=", missing_date(formatter, "6"))
            when 'not_applicable'
              self.send("#{df}=", missing_date(formatter, "7"))
            end
          end
        end
      end
    end

    def missing_date(formatter, n)
      case formatter
      when '%Y-%m'
        return "9#{n*3}-9#{n}"
      else
        return "9#{n*3}-9#{n}-9#{n}"
      end
    end

    def export_versions
      keys = ["when", "who", "what"] + get_attribute_names
      csv_string = FasterCSV.generate do |csv|
        add_headers(csv, keys)
        add_version_values(csv)
        add_object_values(csv)
      end
      csv_string
    end

    def add_headers(csv, keys)
      csv << keys.map {|key| key.titleize}
    end
    private :add_headers

    def add_version_values(csv)
      self.versions.each do |v|
        next if v.object.nil?
        vals = []
        vals << v.created_at.to_s(:db)
        vals << v.whodunnit
        vals << v.event
        v1 = v.event == "update" ? v.reify : v
        get_attribute_names.each { |a| vals << get_value(v1, a) }
        csv << vals
      end
    end
    private :add_version_values

    def add_object_values(csv)
      vals = ["Current Record", "", ""]
      get_attribute_names.each { |a| vals << get_value(self, a) }
      csv << vals
    end
    private :add_object_values

    def get_attribute_names
      (self.attribute_names - ["id"]).sort
    end
    private :get_attribute_names

    def get_value(obj, attribute)
      value = obj[attribute]
      if attribute[-3,3] == "_id" and !value.blank?
        begin
          cls = attribute.titleize.gsub(/ /,'').constantize
          value = cls.find(value).to_s
        rescue
          value = obj[attribute]
        end
      end
      value
    end
    private :get_value

  end

end