class CreateHouseholdForScreenedPersons < ActiveRecord::Migration

  def up
    # get all person ids of people who took Screener
    sql = <<SQL
SELECT distinct(user_id) FROM response_sets
JOIN surveys ON surveys.id = response_sets.survey_id
WHERE surveys.title LIKE '%Screen_INT%';
SQL
    result = ActiveRecord::Base.connection.execute(sql)
    ids = result.map { |id| p id["user_id"].to_i }

    # Create a household record for all people who are not in
    # a household
    people = Person.find(ids).select { |per| per.in_household? == false }
    people.each do |person|
      household = HouseholdUnit.create(:psu_code => person.psu_code)
      HouseholdPersonLink.create(:person => person,
                                 :household_unit => household,
                                 :is_active_code => NcsCode::YES)

      # if that person has children, associate the children with the
      # newly created household unit
      if !person.participant.try(:children).blank?
        person.participant.children.each do |child|
          HouseholdPersonLink.create(:person => child,
                                     :household_unit => household,
                                     :is_active_code => NcsCode::YES)
        end
      end
    end

  end

  def down
    # NOOP
  end
end
