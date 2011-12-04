require 'ncs_navigator/core/warehouse'
# To preload the same version of the models used by OperationalEnumerator
require 'ncs_navigator/core/warehouse/operational_enumerator'

require 'forwardable'

module NcsNavigator::Core::Warehouse
  ##
  # A utility that takes the entire contents of an MDES Warehouse
  # instance and initializes or updates this Core deployment's
  # operational tables to match its contents.
  #
  # The mappings from the MDES Warehouse to Core tables are defined in
  # {OperationalEnumerator}.
  class OperationalImporter
    extend Forwardable

    attr_reader :wh_config

    def_delegators self, :automatic_producers

    def initialize(wh_config)
      @wh_config = wh_config
      @core_models_indexed_by_table = {}
      @public_id_indexes = {}
      NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config).set_up_repository
    end

    def import(*tables)
      automatic_producers.
        select { |rp| tables.empty? || tables.include?(rp.name) }.
        each do |one_to_one_producer|
        create_core_records(one_to_one_producer)
      end
    end

    def self.automatic_producers
      OperationalEnumerator.record_producers.reject { |rp|
        %w(LinkContact).include?(rp.model.to_s.demodulize)
      }
    end

    def create_core_records(mdes_producer)
      core_model = core_model_for_table(mdes_producer.name)
      core_ids = public_id_index(core_model)
      column_map = mdes_producer.column_map(core_model.attribute_names)
      mdes_producer.model.all.each do |mdes_record|
        mdes_key = mdes_record.key.first
        if existing_id = core_ids[mdes_key]
          update_core_record(core_model.find(existing_id), mdes_record, column_map)
        else
          update_core_record(core_model.new, mdes_record, column_map)
        end
      end
    end

    private

    def update_core_record(core_record, mdes_record, column_map)
      column_map.each do |core_attribute, mdes_variable|
        if core_attribute =~ /^public_id_for_/
          # This is the format generated in DatabaseEnumeratorHelpers for
          # joined public ID columns
          associated_table, core_model_association_id =
            (core_attribute.scan /^public_id_for_(.*)_as_(.*)$/).first

          associated_model = core_model_for_table(associated_table)
          associated_public_id = mdes_record.send(mdes_variable)

          new_association_id = public_id_index(associated_model)[associated_public_id]
          unless new_association_id
            wh_config.log.error(
              "MDES association #{mdes_record.class.mdes_table_name}[#{mdes_record.key.first}]##{mdes_variable} refers to a record that is not present in Core.")
          end
          core_record.send("#{core_model_association_id}=", new_association_id)
        else
          core_record.send("#{core_attribute}=", mdes_record.send(mdes_variable))
        end
      end
      core_record.save!
      public_id_index(core_record.class)[mdes_record.key.first] = core_record.id
    end

    def core_model_for_table(name)
      name = name.to_s
      @core_models_indexed_by_table[name] ||= Object.const_get(name.singularize.camelize)
    end

    ##
    # @return [Hash<String, Fixnum>] a mapping from public IDs to
    #   internal IDs for the given model.
    def public_id_index(core_model)
      @public_id_indexes[core_model.table_name] ||= build_public_id_index(core_model)
    end

    def build_public_id_index(core_model)
      index_query =
        "SELECT id, #{core_model.public_id_field} AS public_id FROM #{core_model.table_name}"
      ActiveRecord::Base.connection.
        select_all(index_query).
        inject({}) do |idx, row|
        idx[row['public_id']] = row['id']
        idx
      end
    end
  end
end
