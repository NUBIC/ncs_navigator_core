module NcsNavigator::Core::Mdes
  ##
  # The current MDES version for this particular Cases deployment.
  class Version
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
            raise "This deployment already has an MDES version (#{current['number']}). Upgrades aren't implemented yet (#2090)."
          end
        else
          conn.execute("INSERT INTO mdes_version (number) VALUES (%s)" % conn.quote(new_number))
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
  end
end
