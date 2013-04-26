# -*- coding: utf-8 -*-

require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  class IneligibleBatchEnumerator
    include NcsNavigator::Warehouse::Transformers::Database

    bcdatabase :name => 'ncs_navigator_core'

    produce_records(
      :ineligible_batches,
      :query => "SELECT * FROM ineligible_batches"
    ) do |row, meta|
      result = []
      row.people_count.times do |idx|
        public_id = "#{row.batch_id}-#{idx}"
        result.push(
          meta[:configuration].model(:person).new.tap do |per|
            per.person_id = public_id
            per.psu_id = row.psu_code
            per.age_range = -4
            per.deceased = -4
            per.ethnic_group = -4
            per.maristat = -4
            per.move_info = -4
            per.p_info_source = -4
            per.p_tracing = -4
            per.person_id = -4
            per.person_lang = -4
            per.plan_move = -4
            per.pref_contact = -4
            per.prefix = -4
            per.psu_id = -4
            per.sex = -4
            per.suffix = -4
            per.when_move = -4

            if meta[:configuration].mdes.version.to_d >= 3.0
              per.person_lang_new = -4
            end
          end
        )

        result.push(
          meta[:configuration].model(:link_person_provider).new.tap do |lpp|
            lpp.is_active = -4
            lpp.person_id = public_id
            lpp.person_provider_id = public_id
            lpp.provider_id = row.provider_id
            lpp.prov_intro_outcome = row.provider_intro_outcome_code
            lpp.prov_intro_outcome_oth = row.provider_intro_outcome_other
            lpp.psu_id = row.psu_code

            if meta[:configuration].mdes.version.to_d >= 3.0
              lpp.date_first_visit = row.date_first_visit_date
              lpp.pre_screening_status = row.pre_screening_status_code
              lpp.sampled_person = row.sampled_person_code
            end
          end
        )

        if meta[:configuration].mdes.version.to_d >= 3.0
          spi = meta[:configuration].model(:sampled_persons_ineligibility).new(
            :age_eligible => row.age_eligible_code,
            :county_of_residence => row.county_of_residence_code,
            :first_prenatal_visit => row.first_prenatal_visit_code,
            :ineligible_by => row.ineligible_by_code,
            :person_id => public_id,
            :pregnancy_eligible => row.pregnancy_eligible_code,
            :provider_id => row.provider_id,
            :psu_id => row.psu_code,
            :sampled_persons_inelig_id => public_id
          )

          sampled_values = [
            row.age_eligible_code,
            row.county_of_residence_code,
            row.first_prenatal_visit_code,
            row.ineligible_by_code,
            row.pregnancy_eligible_code
          ].uniq
          result.push(spi) unless sampled_values.count == 1 && sampled_values.first == -4
        end
      end
      result
    end

  end
end
