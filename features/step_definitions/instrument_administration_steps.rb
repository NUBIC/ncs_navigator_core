Given /^the child$/ do |table|
  rh = table.rows_hash

  # Set up the child.
  mother_name = rh.delete('mother')

  child = Factory(:person, table.rows_hash)
  child_p = Factory(:participant, :p_type_code => 6)
  Factory(:participant_person_link, :participant => child_p, :person => child, :relationship_code => 1)

  # If we want a mother, set one up.
  #
  # This mother has to be registered with PSC because code in
  # SurveyorController currently assumes that.  (Curiously, there is no such
  # requirement on the child.)  The 'registered_with_psc' person ID is a
  # sentinel value used to trigger FakeWeb interception; see
  # features/support/fakeweb.rb.
  if mother_name
    mother = Factory(:person, :first_name => mother_name, :person_id => 'registered_with_psc')
    mother_p = Factory(:participant)
    Factory(:participant_person_link, :participant => mother_p, :person => mother, :relationship_code => 1)
    Factory(:participant_person_link, :participant => child_p, :person => mother, :relationship_code => 2)
  end
end

Given /^"([^"]*)" has pending work in Cases$/ do |name|
  person = Person.where(:first_name => name).first

  Factory(:contact_link, :event => Factory(:event), :person => person)
end

Given /^the survey$/ do |survey_spec|
  Surveyor::Parser.new.parse(survey_spec)
end

When /^I administer "([^"]*)" to "([^"]*)" via "([^"]*)"$/ do |title, subject, respondent|
  # This step assumes that, in the world of the scenario, the first contact
  # link we find on the named Person is what we'll use.  This is a brutally
  # coarse assumption but it's good enough for all scenarios that currently use
  # this step.  If you need more nuanced behavior, please do add it.
  sp = Person.where(:first_name => subject).first
  rp = Person.where(:first_name => respondent).first
  cl = rp.contact_links.first

  s = Survey.where(:title => title).first

  params = {
    :participant_id => sp.participant.id,
    :contact_link_id => cl.id,
    :survey_access_code => s.access_code
  }

  visit start_instrument_person_path(rp.id, params)
end

When /^I change "([^"]*)"'s first name to "([^"]*)"$/ do |old_name, new_name|
  Person.where(:first_name => old_name).first.update_attribute(:first_name, new_name)
end

When /^I edit "([^"]*)"'s responses for "([^"]*)"$/ do |respondent, title|
  person = Person.where(:first_name => respondent).first
  survey = Survey.where(:title => title).first
  rs_access_code = ResponseSet.where(:user_id => person.id).first.access_code

  visit Surveyor::Engine.routes.url_helpers.edit_my_survey_path(survey.access_code, rs_access_code)
end
