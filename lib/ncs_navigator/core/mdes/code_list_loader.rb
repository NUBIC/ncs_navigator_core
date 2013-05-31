# -*- coding: utf-8 -*-
require 'ncs_navigator/mdes'
require 'yaml'

module NcsNavigator::Core::Mdes
  class CodeListLoader
    attr_reader :mdes_version, :automatic_filename, :future_filename, :pg_dump_filename

    def initialize(options = {})
      @interactive = options[:interactive]
      ver = options[:mdes_version]
      @mdes_version = if ver
        Version.new(ver)
      else
        NcsNavigatorCore.mdes_version
      end

      @automatic_filename = Rails.root + 'db' + "ncs_codes-#{mdes_version.number}.yml"
      @future_filename = Rails.root + 'db' + "ncs_codes-#{mdes_version.number}-future.yml"
      @pg_dump_filename = Rails.root + 'db' + "ncs_codes-#{mdes_version.number}.pgcustom"
    end

    def interactive?
      @interactive
    end

    # n.b.: if you change the way this method works, you should run
    # `rake mdes:code_lists:all` and commit the result.
    def create_yaml
      current_types = mdes_version.specification.types.select(&:code_list)
      create_yaml_from_types(current_types, automatic_filename)
      create_yaml_from_types(future_code_list_types(current_types), future_filename)
    end

    def create_yaml_from_types(variable_types, pathname)
      yml = variable_types.collect { |typ|
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

      pathname.open('w:utf-8') do |w|
        w.write(yml.to_yaml)
      end
    end
    private :create_yaml_from_types

    def future_code_list_types(current_types)
      future_versions = SUPPORTED_VERSIONS.select { |ver| mdes_version < ver }.
        sort.collect { |future_ver| Version.new(future_ver) }

      present_lists = current_types.collect { |t| t.name.upcase }

      future_versions.each_with_object([]) do |future_ver, future_code_lists|
        new_types = future_ver.specification.types.select(&:code_list).
          reject { |type| present_lists.include?(type.name.upcase) }
        present_lists.concat(new_types.collect { |t| t.name.upcase })
        future_code_lists.concat(new_types)
      end
    end
    private :future_code_list_types

    # Creates a PG custom dump file that contains the code lists in the current
    # environment's database.
    #
    # n.b.: if you change the way this method works, you should run
    # `rake mdes:code_lists:all` and commit the result.
    def create_pg_dump
      create_tmp_pgpass_if_necessary

      cmd = [
        'pg_dump',
        '--format', 'custom',
        '--table', 'ncs_codes',
        '--no-owner',
        '--no-acl',
        '--file', pg_dump_filename
      ]
      cmd << '-h' << database_params['host'] if database_params['host']
      cmd << '-p' << database_params['port'] if database_params['port']
      cmd << '-U' << database_params['username']
      cmd << database_params['database']

      if interactive?
        $stderr.puts quoted_cmd_string(cmd)
      end
      system(quoted_cmd_string(cmd))
    end

    ##
    # Modifies the contents of the ncs_codes table to reflect the selected
    # MDES version.
    #
    # Pro vs {#load_from_pg_dump}: Existing records are updated -- not
    # removed and replaced. If there are FKs that point to ncs_codes, they
    # won't be interfered with.
    #
    # Con vs. {#load_from_pg_dump}: much, much slower.
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
              INSERT INTO ncs_codes (local_code, list_name, display_text, created_at, updated_at)
              VALUES (?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            ), %w(local_code list_name display_text).map { |k| entry[k] })
        end

        partitioned[:delete].each do |entry|
          do_update(
            %Q(DELETE FROM ncs_codes WHERE local_code=? AND list_name=?),
            %w(local_code list_name).collect { |k| entry[k] })
        end
      end

      Rails.application.code_list_cache.reset

      Rails.logger.info "Changed NcsCodes: inserted %d, updated %d, deleted %d." % [
        partitioned[:insert].size, partitioned[:update].size, partitioned[:delete].size
      ]
      $stderr.puts "done." if interactive?
    end

    ##
    # Truncates and replaces the full contents of the ncs_codes table using the
    # stored `pgcustom` file.
    #
    # @see #load_from_yaml for pros and cons.
    def load_from_pg_dump
      create_tmp_pgpass_if_necessary

      ActiveRecord::Base.connection.execute('TRUNCATE ncs_codes')

      cmd = [
        'pg_restore',
        '--format', 'custom',
        '--data-only',
        '--no-owner',
        '--single-transaction',
      ]
      cmd << '-h' << database_params['host'] if database_params['host']
      cmd << '-p' << database_params['port'] if database_params['port']
      cmd << '-U' << database_params['username']
      cmd << '-d' << database_params['database']
      cmd << pg_dump_filename

      if interactive?
        $stderr.puts quoted_cmd_string(cmd)
      else
        Rails.logger.info(quoted_cmd_string(cmd))
      end
      system(quoted_cmd_string(cmd)) or fail "load_from_pg_dump failed. See output."
    end

    ##
    # Returns the stored YAML code values for this loader.
    # @return [Array<Hash>]
    def yaml_entries
      yaml_entries = YAML.load(automatic_filename.read)
      if future_filename.exist?
        yaml_entries += YAML.load(future_filename.read)
      end
      yaml_entries
    end

    def quoted_cmd_string(cmd)
      "'#{cmd.join("' '")}'"
    end
    private :quoted_cmd_string

    def do_update(sql, params)
      conn = ActiveRecord::Base.connection
      conn.update(sql.gsub('?') { conn.quote(params.shift) })
    end
    private :do_update

    def select_for_insert_update_delete
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

    def database_params
      ActiveRecord::Base.configurations[Rails.env]
    end

    def create_tmp_pgpass_if_necessary
      @tmp_pgpass ||= Tempfile.new('cl-pgpass').tap do |tempfile|
        tempfile.puts [
          database_params['host'] || 'localhost',
          database_params['port'] || '*',
          '*',
          database_params['username'],
          database_params['password']
        ].join(':')
        tempfile.close

        ENV['PGPASSFILE'] = tempfile.path
      end
    end
    private :create_tmp_pgpass_if_necessary
  end
end

