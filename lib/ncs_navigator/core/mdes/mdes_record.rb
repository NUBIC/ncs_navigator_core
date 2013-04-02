# -*- coding: utf-8 -*-

require 'active_support/concern'
require 'uuidtools'

module NcsNavigator::Core::Mdes
  module MdesRecord
    extend ActiveSupport::Concern

    DEFAULT_DATE_FORMAT = '%Y-%m-%d'

    included do
      before_create :set_public_id
      before_validation :set_psu_code
      before_validation :set_missing_in_error
      before_save :format_dates

      include NcsNavigator::Core::HasPublicId

      MdesRecord.models << self
    end

    module ClassMethods
      def acts_as_mdes_record(options = {})
        send :include, InstanceMethods
        cattr_accessor :public_id_field
        cattr_accessor :public_id_kind
        cattr_accessor :public_id_generator
        cattr_accessor :date_fields

        self.public_id_field = (options[:public_id_field] || :uuid)

        self.public_id_generator = if options[:public_id_generator]
                                     options[:public_id_generator]
                                   else
                                     UuidPublicIdGenerator
                                   end

        set_up_and_verify_public_id_generator

        if options[:date_fields]
          self.date_fields = options[:date_fields]
          options[:date_fields].each do |df|
            attr_accessor "#{df}_modifier"
          end
        end
      end

      def ncs_coded_attribute(attribute_name, options)
        if String === options
          options = { :list_name => options }
        end

        ncs_coded_attributes[attribute_name.to_sym] =
          NcsNavigator::Core::Mdes::NcsCodedAttribute.new(self, attribute_name, options)
      end

      def ncs_coded_attributes
        @ncs_coded_attributes ||= {}
      end

      def mdes_time_pattern
        @mdes_time_pattern ||= /^(9\d:\d\d)|(([01]\d|2[0-3]):[0-5]\d)$/
      end

      private

      def set_up_and_verify_public_id_generator
        unless self.public_id_generator.respond_to?(:generate)
          fail "Specified public_id_generator #{self.public_id_generator.inspect} does not respond to :generate."
        end

        {
          :model_class => self,
          :public_id_field => self.public_id_field
        }.each do |possible_attr, value|
          setter = "#{possible_attr}="
          if self.public_id_generator.respond_to?(setter)
            self.public_id_generator.send(setter, value)
          end
        end
      end
    end

    ##
    # @private
    class UuidPublicIdGenerator
      def self.generate
        UUIDTools::UUID.random_create.to_s
      end
    end

    module InstanceMethods
      def set_public_id
        self.send("#{self.public_id_field}=", public_id_generator.generate) if self.public_id.blank?
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
        self.class.ncs_coded_attributes.values.each do |nca|
          if send(nca.foreign_key_getter).nil?
            send(nca.foreign_key_setter, -4)
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

      def set_psu_code
        if (NcsNavigatorCore && !NcsNavigatorCore.psu.blank? &&
            self.attribute_names.include?('psu_code') && self.psu_code.blank?)
          self.psu_code = NcsNavigatorCore.psu.to_i
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
        csv_string = Rails.application.csv_impl.generate do |csv|
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

    def self.models
      @models ||= []
    end

  end
end
