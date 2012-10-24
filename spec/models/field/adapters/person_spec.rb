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
