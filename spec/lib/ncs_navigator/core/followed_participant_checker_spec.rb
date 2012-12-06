require 'spec_helper'

module NcsNavigator::Core
  describe FollowedParticipantChecker do
    let(:csv_filename) { Rails.root + 'tmp' + 'fpc-test.csv' }

    let(:checker) { FollowedParticipantChecker.new(csv_filename, :quiet => true) }

    def create_csv(*lines)
      csv_filename.open('w') do |f|
        lines.each do |line|
          f.puts line.join(',')
        end
      end
    end

    describe '#expected_participants' do
      before do
        create_csv(
          %w(p_id),
          %w(A123),
          %w(B822)
        )
      end

      it 'reads the participants from the CSV' do
        checker.expected_participants.collect(&:p_id).should == %w(A123 B822)
      end

      it 'uses Hi for all participants if intensity column not present' do
        checker.expected_participants.collect(&:intensity).should == [:high, :high]
      end

      describe 'with an intensity column' do
        before do
          create_csv(
            %w(P_ID Intensity),
            %w(A340 hi),
            %w(B567),
            %w(B312 lo)
          )
        end

        it 'reads the intensities from the CSV if present' do
          checker.expected_participants.collect(&:intensity).should == [:high, nil, :low]
        end

        it 'records an error if intensity column is present but blank' do
          checker.expected_participants.find { |p| p.p_id == 'B567' }.errors.should ==
            ['Participant B567 does not have an intensity value']
        end
      end
    end

    describe '#differences' do
      before do
        create_csv(
          %w(p_id),
          %w(M),
          %w(N),
          %w(O)
        )

        Factory(:participant, :p_id => 'M', :high_intensity => true, :being_followed => true)
        Factory(:participant, :p_id => 'N', :high_intensity => true, :being_followed => false)
        # O not present
        Factory(:participant, :p_id => 'Q', :high_intensity => true, :being_followed => true)
      end

      it 'knows when a participant in the CSV is completely missing from Cases' do
        checker.differences[:missing_from_cases].should == %w(O)
      end

      it 'knows when a participant in the CSV is not being followed in Cases' do
        checker.differences[:expected_followed].should == %w(N)
      end

      it 'knows when a participant being followed in Cases is not in the CSV' do
        checker.differences[:expected_not_followed].should == %w(Q)
      end

      it 'does not report anything about a matching participant' do
        checker.differences.values.flatten.should_not include('M')
      end

      describe 'with an intensity column' do
        before do
          create_csv(
            %w(P_id INTENSITY),
            %w(HH Hi),
            %w(HL HI),
            %w(LL lo),
            %w(LH lO)
          )

          Factory(:participant, :high_intensity => true,  :p_id => 'HH')
          Factory(:participant, :high_intensity => false, :p_id => 'HL')
          Factory(:participant, :high_intensity => true,  :p_id => 'LH')
          Factory(:participant, :high_intensity => false, :p_id => 'LL')
        end

        it 'knows when a participant is Hi in the CSV but Lo in Cases' do
          checker.differences[:expected_high].should == %w(HL)
        end

        it 'knows when a participant is Lo in the CSV but Hi in Cases' do
          checker.differences[:expected_low].should == %w(LH)
        end

        it 'does not report a participant that is Hi in both' do
          checker.differences.values.flatten.should_not include('HH')
        end

        it 'does not report a participant that is Lo in both' do
          checker.differences.values.flatten.should_not include('LL')
        end
      end
    end

    describe '#update!' do
      def p(p_id)
        Participant.where(:p_id => p_id).first
      end

      before do
        create_csv(
          %w(p_id intensity),
          %w(G  Lo),
          %w(E  Lo),
          %w(HL Hi),
          %w(LH Lo)
        )

        Factory(:participant, :p_id => 'G',  :being_followed => true)
        Factory(:participant, :p_id => 'E',  :being_followed => false)
        Factory(:participant, :p_id => 'N',  :being_followed => true)
        Factory(:participant, :p_id => 'HL', :being_followed => true, :high_intensity => false)
        Factory(:participant, :p_id => 'LH', :being_followed => true, :high_intensity => true)

        with_versioning do
          checker.update!
        end
      end

      it 'changes an expected-but-not-followed participant to followed' do
        p('E').being_followed.should be_true
      end

      it 'changes a not-expected-but-followed participant to not followed' do
        p('N').being_followed.should be_false
      end

      it 'changes an expected-but-not-high participant to high' do
        p('HL').should_not be_low_intensity
      end

      it 'changes an expected-but-not-low participant to low' do
        p('LH').should be_low_intensity
      end

      it 'leaves other participants alone' do
        p('G').versions.collect(&:event).should_not include('update')
      end

      it 'audits changes as coming from this checker' do
        p('E').versions.where(:event => 'update').first.whodunnit.
          should == "FollowedParticipantChecker(#{csv_filename.basename.to_s})"
      end
    end
  end
end
