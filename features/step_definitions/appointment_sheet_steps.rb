When /^I view my scheduled events for 2013-04-08 to 2013-04-13$/ do
  path = "/?start_date=%222013-04-08%22&end_date=%222013-04-13%22"
  visit(path)
end

When /^I view the appointment sheet for ("[^"]*")/ do |name|
  step "I view my scheduled events for 2013-04-08 to 2013-04-13"
  click_link "Appointment sheet for #{name}"
end

Given /^the scheduled participant$/ do |table|
  person_attrs, p_attrs = table.raw.partition { |k, v| k =~ /^person/ }
  person_attrs.map! { |k, v| [k.sub('person/', ''), v] }

  @person = Person.create!(Hash[*person_attrs.flatten])
  @participant = Participant.create!(Hash[*p_attrs.flatten])

  @participant.person = @person
  @participant.save!
end

Given /^whose scheduled event is$/ do |table|
  data = table.rows_hash
  type_name = data.delete('event_type')

  code = NcsCode.for_list_name_and_display_text('EVENT_TYPE_CL1', type_name)
  raise "Unknown event type #{type_name}" unless code

  event = Event.create!(data.merge( :event_type => code,
                                    :event_start_date => data['event_start_date']))

  @participant.events << event
  @participant.save!
end

Given /^whose address is$/ do |table|
  data = table.rows_hash

  state = NcsCode.for_list_name_and_local_code('STATE_CL1', 21)

  address = Address.create!(data.merge(:address_rank_code => data['address_rank_code'],
                                       :address_one => data['address_one'],
                                       :address_two => data['address_two'],
                                       :city => data['city'],
                                       :state => state,
                                       :zip => data['20850']))

  @person.addresses << address
  @person.save!
end

Given /^whose cellphone is (\d*-\d*-\d*)$/ do |phone|
  phone = Telephone.create!(:phone_rank_code => 1,
                            :phone_type_code => 3,
                            :phone_nbr => phone)
  @person.telephones << phone
  @person.save!
end

Given /^whose homephone is (\d*-\d*-\d*)$/ do |phone|
  phone = Telephone.create!(:phone_rank_code => 1,
                            :phone_type_code => 1,
                            :phone_nbr => phone)
  @person.telephones << phone
  @person.save!
end

Given /^has a general consent$/ do
  @general_consent = ParticipantConsent.create!(:consent_type_code => nil)
  @participant.participant_consents << @general_consent
  @participant.save!
end

Given /^who has (.+)$/ do |consent_type|
  code = NcsCode.for_list_name_and_display_text('CONSENT_TYPE_CL2', consent_type)
  sample_consent = ParticipantConsentSample.create!(:sample_consent_type_code => code)
  @participant.participant_consent_samples << sample_consent
  @participant.save!
end

Given /^whose due date is "([^"]*)"$/ do |due_date|
  ppg_detail = PpgDetail.create!(:participant_id => @participant,
                                 :orig_due_date => '2012-09-12')
end

Given /^whose child is$/ do |table|
  person_attrs, p_attrs = table.raw.partition { |k, v| k =~ /^person/ }
  person_attrs.map! { |k, v| [k.sub('person/', ''), v] }

  @child_person = Person.create!(Hash[*person_attrs.flatten])
  @child_participant = Participant.create!(Hash[*p_attrs.flatten])

  @child_participant.person = @child_person
  @child_participant.save!

  ParticipantPersonLink.create!(:person => @child_person, :participant => @participant, :relationship_code => 8)
end

Given /^child has a general consent$/ do
  @child_general_consent = ParticipantConsent.create!(:consent_type_code => nil)
  @child_participant.participant_consents << @child_general_consent
  @child_participant.save!
end

Given /^the child has (.+)$/ do |consent_type|
  code = NcsCode.for_list_name_and_display_text('CONSENT_TYPE_CL2', consent_type)
  sample_consent = ParticipantConsentSample.create!(:sample_consent_type_code => code)
  @child_participant.participant_consent_samples << sample_consent
  @child_participant.save!
end

Given /^whose next event is$/ do |table|
  data = table.rows_hash
  type_name = data.delete('event_type')

  code = NcsCode.for_list_name_and_display_text('EVENT_TYPE_CL1', type_name)
  raise "Unknown event type #{type_name}" unless code

  event = Event.create!(data.merge( :event_type => code,
                                    :event_start_date => data['event_start_date']))

  @participant.events << event
  @participant.save!
end

Given /^speaks english$/ do
  @person.update_attribute(:language_code, 1)
end

Given /^is a boy$/ do
  @child_person.update_attribute(:sex_code, 1)
end

Then /^I should see ("[^"]*") scheduled for ("[^"]*") for a ("[^"]*") event$/ do |name, date, event|
  step "I should see #{name}"
  step "I should see #{date}"
  step "I should see #{event}"
end

Then /^I should see ("[^"]*") scheduled for ("[^"]*") for a ("[^"]*") event at ("[^"]*")$/ do |name, date, event, time|
  step "I should see #{name}"
  step "I should see #{date}"
  step "I should see #{event}"
  step "I should see #{time}"
end

Then /^I should see scheduled event ("[^"]*")$/ do |event|
  step "I should see #{event}"
end

Then /^I should see the event date of ("[^"]*") and start time of ("[^"]*")$/ do |date, time|
  step "I should see #{date}"
  step "I should see #{time}"
end

Then /^I should see the address of ("[^"]*"), ("[^"]*"), ("[^"]*")$/ do |address1, address2, city_state|
  step "I should see #{address1}"
  step "I should see #{address2}"
  step "I should see #{city_state}"
end

Then /^I should see the cell phone number ("[^"]*") and home phone number of ("[^"]*")$/ do |cell, home|
  step "I should see #{cell}"
  step "I should see #{home}"
end

Then /^I should see the participant's name, ("[^"]*"), and public id, ("[^"]*")$/ do |name, id|
  step "I should see #{name}"
  step "I should see #{id}"
end

Then /^I should see that see speaks ("[^"]*")$/ do |language|
  step "I should see #{language}"
end

Then /^I should see that she has consent of ("[^"]*")$/ do |consent|
  step "I should see #{consent}"
end

Then /^I should see that she has a child named ("[^"]*")$/ do |child|
  step "I should see #{child}"
end

Then /^I should see that he is a ("[^"]*")$/ do |sex|
  step "I should see #{sex}"
end

Then /^I should see his age is ("[^"]*")$/ do |age|
  step "I should see #{age}"
end

Then /^I should see the child has consent of ("[^"]*")$/ do |child_consent|
  step "I should see #{child_consent}"
end

Then /^I should see the ("[^"]*") as to be conducted$/ do |instrument|
  step "I should see #{instrument}"
end

Then /^I should the next event as ("[^"]*")$/ do |event|
  step "I should see #{event}"
end
