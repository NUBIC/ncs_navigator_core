# == Schema Information
#
# Table name: people
#
#  age                            :integer
#  age_range_code                 :integer          not null
#  being_processed                :boolean          default(FALSE)
#  created_at                     :datetime
#  date_move                      :string(7)
#  date_move_date                 :date
#  deceased_code                  :integer          not null
#  ethnic_group_code              :integer          not null
#  first_name                     :string(30)
#  id                             :integer          not null, primary key
#  language_code                  :integer          not null
#  language_new_code              :integer
#  language_new_other             :string(255)
#  language_other                 :string(255)
#  last_name                      :string(30)
#  lock_version                   :integer          default(0)
#  maiden_name                    :string(30)
#  marital_status_code            :integer          not null
#  marital_status_other           :string(255)
#  middle_name                    :string(30)
#  move_info_code                 :integer          not null
#  p_info_date                    :date
#  p_info_source_code             :integer          not null
#  p_info_source_other            :string(255)
#  p_info_update                  :date
#  p_tracing_code                 :integer          not null
#  person_comment                 :text
#  person_dob                     :string(10)
#  person_dob_date                :date
#  person_id                      :string(36)       not null
#  planned_move_code              :integer          not null
#  preferred_contact_method_code  :integer          not null
#  preferred_contact_method_other :string(255)
#  prefix_code                    :integer          not null
#  psu_code                       :integer          not null
#  response_set_id                :integer
#  role                           :string(255)
#  sex_code                       :integer          not null
#  suffix_code                    :integer          not null
#  title                          :string(5)
#  transaction_type               :string(36)
#  updated_at                     :datetime
#  when_move_code                 :integer          not null
#

require 'spec_helper'

module Field::Adapters
  describe Person::ModelAdapter do
    let(:person) { ::Person.new }
    let(:adapter) { Person::ModelAdapter.new(person) }

    describe '#pending_postrequisites' do
      describe 'if #source is not set' do
        before do
          adapter.source = nil
        end

        it 'is empty' do
          adapter.pending_postrequisites.should be_empty
        end
      end

      let(:ha) { Person::HashAdapter.new({}) }

      before do
        adapter.source = ha
      end

      it "returns the person's public ID" do
        ha.person_id = 'foo'

        adapter.pending_postrequisites[::Person].should == ['foo']
      end

      it "returns the participant's public ID" do
        pa = Participant::HashAdapter.new({})
        pa.p_id = 'bar'
        ha.ancestors[:participant] = pa

        adapter.pending_postrequisites[::Participant].should == ['bar']
      end
    end

    describe '#ensure_postrequisites' do
      let(:ha) { Person::HashAdapter.new({}) }
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }

      let(:map) do
        Field::IdMap.new({
          ::Person => { 'foo' => person.id },
          ::Participant => { 'bar' => participant.id }
        })
      end

      before do
        pa = Participant::HashAdapter.new({})
        pa.p_id = 'bar'
        ha.ancestors[:participant] = pa
        ha.person_id = 'foo'
        ha.relationship_code = 1

        adapter.source = ha
      end

      describe "if a matching ParticipantPersonLink doesn't exist" do
        before do
          ParticipantPersonLink.delete_all
        end

        it 'creates a ParticipantPersonLink' do
          adapter.ensure_postrequisites(map)

          ParticipantPersonLink.count.should == 1
        end
      end

      describe "if a matching ParticipantPersonLink exists" do
        before do
          ParticipantPersonLink.create!(:person_id => person.id,
                                        :participant_id => participant.id,
                                        :relationship_code => ha.relationship_code)
        end

        it 'does not create another ParticipantPersonLink' do
          adapter.ensure_postrequisites(map)

          ParticipantPersonLink.count.should == 1
        end
      end
    end
  end
end
