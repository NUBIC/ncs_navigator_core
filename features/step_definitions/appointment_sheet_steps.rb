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
  @general_consent = ParticipantConsent.create!(:consent_type_code => nil,
                                                :participant_id => @participant.id)
  @participant.save!
end

Given /^who has (.+)$/ do |consent_type|
  code = NcsCode.for_list_name_and_display_text('CONSENT_TYPE_CL2', consent_type)
  pc = ParticipantConsent.where(:participant_id => @participant.id).first
  sample_consent = ParticipantConsentSample.create!(:sample_consent_type => code,
                                                    :participant_consent => pc)
  @participant.save!
end

Given /^whose due date is "([^"]*)"$/ do |due_date|
  ppg_detail = PpgDetail.create!(:participant_id => @participant.id,
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
  pc = ParticipantConsent.where(:participant_id => @child_participant.id).first
  sample_consent = ParticipantConsentSample.create!(:sample_consent_type => code,
                                                    :participant_consent => pc)
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

Given /^has a last contact comment of "([^"]*)"$/ do |comment|
  contact = Contact.create!(:contact_comment => "Watch out for the big dog!",
                            :contact_date_date => "2013-01-01")
  ContactLink.create!(:contact => contact,
                      :staff_id => "A staff member",
                      :person => @person)
end

Then /^I see ("[^"]*") scheduled for ("[^"]*") for a ("[^"]*") event$/ do |name, date, event|
  steps %{
    And I see #{name}
    And I see #{date}
    And I see #{event}
  }
end

Then /^I see ("[^"]*") scheduled for ("[^"]*") for a ("[^"]*") event at ("[^"]*")$/ do |name, date, event, time|
  steps %{
    And I see #{name}
    And I see #{date}
    And I see #{event}
    And I see #{time}
  }
end

Then /^I see scheduled event ("[^"]*")$/ do |event|
  step "I see #{event}"
end

Then /^I see the event date of ("[^"]*") and start time of ("[^"]*")$/ do |date, time|
  steps %{
    And I see #{date}
    And I see #{time}
  }
end

Then /^I see the address of ("[^"]*"), ("[^"]*"), ("[^"]*")$/ do |address1, address2, city_state|
  steps %{
    And I see #{address1}
    And I see #{address2}
    And I see #{city_state}
  }
end

Then /^I see the cell phone number ("[^"]*") and home phone number of ("[^"]*")$/ do |cell, home|
  steps %{
    And I see #{cell}
    And I see #{home}
  }
end

Then /^I see the participant's name, ("[^"]*"), and public id, ("[^"]*")$/ do |name, id|
  steps %{
    And I see #{name}
    And I see #{id}
  }
end

Then /^I see that see speaks ("[^"]*")$/ do |language|
  step "I see #{language}"
end

Then /^I see that she has consent of ("[^"]*")$/ do |consent|
  step "I see #{consent}"
end

Then /^I see that she has a child named ("[^"]*")$/ do |child|
  step "I see #{child}"
end

Then /^I see that he is a ("[^"]*")$/ do |sex|
  step "I see #{sex}"
end

Then /^I see his age is ("[^"]*")$/ do |age|
  step "I see #{age}"
end

Then /^I see the child has consent of ("[^"]*")$/ do |child_consent|
  step "I see #{child_consent}"
end

Then /^I see the ("[^"]*") as to be conducted$/ do |instrument|
  step "I see #{instrument}"
end

Then /^I see the next event as ("[^"]*")$/ do |event|
  step "I see #{event}"
end

Then /^I see the last comment was ("[^"]*")$/ do |comment|
  step "I see #{comment}"
end
