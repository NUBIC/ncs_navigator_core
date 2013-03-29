module NcsNavigator::Core::Mdes
  ##
  # The current MDES version for this particular Cases deployment.
  class Version
    include Comparable

    ##
    # Set the MDES version for a new deployment.
    #
    # @param [String] new_number
    def self.set!(new_number)
      fail 'MDES version cannot be blank.' if new_number.blank?

      ActiveRecord::Base.connection.tap do |conn|
        current = conn.select_one('SELECT number FROM mdes_version')
        if current
          if current['number'] != new_number
            raise "This deployment already has an MDES version (#{current['number']}). Use a migrator to change MDES versions."
          end
        else
          conn.execute("INSERT INTO mdes_version (number) VALUES (%s)" % conn.quote(new_number))
        end
      end
    end

    ##
    # Change the MDES version for a deployment.
    #
    # This is intended to be called from a migration only, in conjunction with
    # making whatever changes are necessary to semantically change the deployed
    # version.
    #
    # @see VersionMigrator
    def self.change!(new_number)
      fail 'MDES version cannot be blank.' if new_number.blank?

      ActiveRecord::Base.connection.tap do |conn|
        current = conn.select_one('SELECT number FROM mdes_version')
        if current
          conn.execute("UPDATE mdes_version SET number=%s" % conn.quote(new_number))
        else
          raise "No MDES version set for this deployment yet."
        end
      end
    end

    def initialize(number=nil)
      @number = number
    end

    ##
    # @return [String] the current configured version number. If none has been
    #   configured, it throws an exception.
    def number
      @number ||= begin
        result = ActiveRecord::Base.connection.select_one('SELECT number FROM mdes_version')

        if result
          result['number']
        else
          fail 'No MDES version set for this deployment yet.'
        end
      end
    end

    ##
    # @return [NcsNavigator::Mdes::Specification] a memoized specification for
    #   the current number.
    def specification
      @specification ||= NcsNavigator::Mdes(number)
    end

    def specification=(spec)
      @specification = spec
    end

    ##
    # Compares to another value. An instance of this class is comparable to:
    #
    # * Other instances. {#number} is compared lexicographically (good till 10.0).
    # * `String`s. This instance's {#number} is compared to the string lexicographically.
    #
    # @return [-1, 0, 1, nil] per the contract defined in `Comparable`.
    def <=>(other)
      case other
      when self.class
        number <=> other.number
      when String
        number <=> other
      else
        nil
      end
    end
  end
end
