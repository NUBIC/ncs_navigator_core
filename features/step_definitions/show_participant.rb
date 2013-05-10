Given /^a participant with scheduled activities$/ do

  child = Factory(:participant_person_link,
                  :person => Factory(:person, :person_dob => Time.zone.today.to_s(:db)),
                  :participant => Factory(:participant, :p_type_code => 6, :high_intensity => true))

  mother  = Factory(:participant_person_link,
                    :person => Factory(:person, :person_id => "w324-rteb-2c7z"),
                    :participant => Factory(:participant, :high_intensity => true))

  link = Factory(:participant_person_link,
                 :participant => child.participant,
                 :person => mother.person,
                 :relationship_code => 2) # mother

  link = Factory(:participant_person_link,
                 :participant => mother.participant,
                 :person => child.person,
                 :relationship_code => 8) # child

  Factory(:event, :event_type_code => Event.informed_consent_code, :participant => mother.participant, :psc_ideal_date => "2013-08-10")
  Factory(:event, :event_type_code => Event.three_month_visit_code, :participant => mother.participant, :psc_ideal_date => "2013-08-10")
  Factory(:event, :event_type_code => Event.birth_code, :participant => mother.participant, :psc_ideal_date => "2013-05-10")
end

Then /^activities should be grouped by date then event$/ do
  within("div#patient_study_calendar_tab") do
    assert page.has_css?("div.schedule div.day" ,:visible =>true, :count => 2)
    assert page.all("div.schedule div.day")[0].has_content?("2013-05-10")
    assert page.all("div.schedule div.day")[0].has_content?("Event: Birth")
    assert page.all("div.schedule div.day")[0].has_content?("Birth Interview Part One")
    assert page.all("div.schedule div.day")[0].has_content?("Birth Interview Part Two")

    assert page.all("div.schedule div.day")[1].has_content?("2013-08-10")

    assert page.all("div.schedule div.day")[1].all("div.activities")[0].has_content?("Event: Informed Consent")
    assert page.all("div.schedule div.day")[1].all("div.activities")[0].has_content?("Informed Consent")

    assert page.all("div.schedule div.day")[1].all("div.activities")[1].has_content?("Event: 3 Month")
    assert page.all("div.schedule div.day")[1].all("div.activities")[1].has_content?("3-Month Mother Phone Interview Child Detail")
    assert page.all("div.schedule div.day")[1].all("div.activities")[1].has_content?("3-Month Mother Phone Interview Child Habits")
  end
end
