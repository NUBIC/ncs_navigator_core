# -*- coding: utf-8 -*-
require 'ncs_navigator/mdes'
require 'yaml'

module NcsNavigator::Core::Mdes
  class CodeListLoader
    attr_reader :mdes_version, :automatic_filename, :manual_filename

    def initialize(options = {})
      @interactive = options[:interactive]
      ver = options[:mdes_version]
      @mdes_version = if ver
        Version.new(ver)
      else
        NcsNavigatorCore.mdes_version
      end

      @automatic_filename = Rails.root + 'db' + "ncs_codes-#{mdes_version.number}.yml"
      @manual_filename = Rails.root + 'db' + "ncs_codes-#{mdes_version.number}-additions.yml"
    end

    def interactive?
      @interactive
    end

    # n.b.: if you change the way this method works, you should run
    # `rake mdes:code_lists:all_yaml` and commit the result.
    def create_yaml
      yml = mdes_version.specification.types.select(&:code_list).collect { |typ|
        # Merge display text for duplicate codes. In MDES 2.0, these only occur in PSU_CL1.
        code_list_index = typ.code_list.inject({}) { |i, cl_entry|
          # TODO: some display text entries have lots of random bytes
          # in them. Clean them up sometime.
          display_text = cl_entry.label.strip.gsub(/\s+/, " ")
          (i[cl_entry.value.to_i] ||= []) << display_text
          i
        }
        code_list_index.collect { |local_code, display_texts|
          {
            'list_name' => typ.name.upcase,
            'local_code' => local_code,
            'display_text' => display_texts.join('; ')
          }
        }
      }.flatten.sort_by { |list_entry| [list_entry['list_name'], list_entry['local_code']] }

      File.open(automatic_filename.to_s, 'w:utf-8') do |w|
        w.write(yml.to_yaml)
      end
    end

    def load_from_yaml
      create_yaml unless automatic_filename.exist?

      partitioned = select_for_insert_update_delete

      NcsCode.transaction do
        ActiveRecord::Base.connection.execute("SET LOCAL synchronous_commit TO OFF")

        if interactive?
          $stderr.write("Changing NcsCodes (insert %d - update %d - delete %d) ... " % [
              partitioned[:insert].size, partitioned[:update].size, partitioned[:delete].size
            ])
          $stderr.flush
        end

        partitioned[:update].each do |entry|
          do_update(
            %Q(
               UPDATE ncs_codes SET updated_at=CURRENT_TIMESTAMP, display_text=?
               WHERE local_code=? AND list_name=?
            ), %w(display_text local_code list_name).map { |k| entry[k] })
        end

        partitioned[:insert].each do |entry|
          do_update(
            %Q(
              INSERT INTO ncs_codes (local_code, list_name, display_text, created_at)
              VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ), %w(local_code list_name display_text).map { |k| entry[k] })
        end

        partitioned[:delete].each do |entry|
          do_update(
            %Q(DELETE FROM ncs_codes WHERE local_code=? AND list_name=?),
            %w(local_code list_name).collect { |k| entry[k] })
        end
      end

      Rails.logger.info "Changed NcsCodes: inserted %d, updated %d, deleted %d." % [
        partitioned[:insert].size, partitioned[:update].size, partitioned[:delete].size
      ]
      $stderr.puts "done." if interactive?
    end

    def do_update(sql, params)
      conn = ActiveRecord::Base.connection
      conn.update(sql.gsub('?') { conn.quote(params.shift) })
    end
    private :do_update

    def select_for_insert_update_delete
      yaml_entries = YAML.load(automatic_filename.read)
      if manual_filename.exist?
        yaml_entries += YAML.load(manual_filename.read)
      end
      existing_entries = ActiveRecord::Base.connection.
        select_all('SELECT list_name, local_code FROM ncs_codes')

      modes = yaml_entries.inject(:insert => [], :update => []) do |modes, entry|
        existing = existing_entries.find { |ex|
          %w(list_name local_code).all? { |k| ex[k].to_s == entry[k].to_s }
        }
        if existing
          modes[:update] << entry
          existing_entries.delete existing
        else
          modes[:insert] << entry
        end
        modes
      end
      modes[:delete] = existing_entries

      modes
    end
    private :select_for_insert_update_delete
  end
end

