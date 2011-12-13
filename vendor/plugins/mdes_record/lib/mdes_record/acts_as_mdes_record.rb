require 'active_support/concern'
module MdesRecord
  extend ActiveSupport::Concern

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
      self.send("#{self.public_id_field}=", UUID.new.generate) if self.uuid.blank?
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

          formatter = self.respond_to?("#{df}_formatter") ? self.send("#{df}_formatter") : '%Y-%m-%d'

          dt = self.send("#{df}_date")
          self.send("#{df}=", dt.strftime(formatter)) unless dt.blank?

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

  end

end
