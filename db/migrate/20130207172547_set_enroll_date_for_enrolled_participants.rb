class SetEnrollDateForEnrolledParticipants < ActiveRecord::Migration
  def change
    sql = <<SQL
select item_id, created_at from versions where object_changes like
'%enroll_status_code:
- -4
- 1
%'
or object_changes like
'%enroll_status_code:
- 
- 1
%'
or object_changes like
'%enroll_status_code:
- 2
- 1
%'
SQL
    rs = ActiveRecord::Base.connection.execute(sql)
    Participant.transaction do
      rs.each do |r|
        if participant = Participant.find(r["item_id"])
          dt = participant.participant_consents.where(:consent_given_code => 1).order(:created_at).first.try(:created_at)
          dt = r["created_at"] if dt.blank?
          participant.update_attribute(:enroll_date, dt.to_date)
        end
      end
    end
  end
end
