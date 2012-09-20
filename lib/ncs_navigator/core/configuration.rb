require 'ncs_navigator/core'

require 'ncs_navigator/mdes'
require 'ncs_navigator/configuration'

module NcsNavigator::Core
  ##
  # A facade exposing runtime configuration elements from multiple
  # sources for a Cases deployment.
  class Configuration
    def self.instance
      @instance ||= new
    end

    ##
    # @param suite_configuration [NcsNavigator::Configuration, nil] a
    #   suite configuration to base this config on. If not set, this
    #   configuration will dynamically pull the global configuration
    #   from `NcsNavigator.configuration` as needed.
    def initialize(suite_configuration=nil)
      @suite_configuration = suite_configuration
    end

    def suite_configuration
      # deliberately not memoized; see constructor docs
      @suite_configuration || NcsNavigator.configuration
    end

    # Attributes which are taken directly from the Core section of the
    # suite configuration without coercion or validation.
    %w(
      study_center_name
      study_center_phone_number
      with_specimens
      sync_log_level
    ).each do |attr|
      class_eval <<-RUBY
        def #{attr}
          suite_configuration.core['#{attr}']
        end
      RUBY
    end

    def study_center_short_name
      suite_configuration.study_center_short_name
    end

    def email_prefix
      "[NCS Navigator Cases #{study_center_short_name} #{Rails.env.titlecase}] "
    end

    def mail_from
      suite_configuration.core_mail_from
    end

    def footer_right_logo_path
      footer_logo_path(:right)
    end

    def footer_left_logo_path
      footer_logo_path(:left)
    end

    def footer_logo_path(side)
      suite_configuration.send("footer_logo_#{side}").try(:basename).try(:to_s)
    end
    private :footer_logo_path

    def psu
      suite_configuration.psus.first.try(:id)
    end
    alias :psu_code :psu

    def recruitment_type_id
      suite_configuration.recruitment_type_id.to_i
    end

    def with_specimens?
      with_specimens == 'true'
    end
    alias :expanded_phase_two? :with_specimens?

    ##
    # @return [NcsNavigator::Mdes::Specification] the specification
    #   for the MDES version that Core currently corresponds to.
    def mdes
      mdes_version.specification
    end

    def mdes_version
      @mdes_version ||= Mdes::Version.new
    end

    def mdes_version=(version)
      @mdes_version =
        case version
        when Mdes::Version
          version
        else
          Mdes::Version.new(version.to_s)
        end
    end

    def machine_account_credentials
      ['ncs_navigator_cases', suite_configuration.core_machine_account_password]
    end
  end
end
