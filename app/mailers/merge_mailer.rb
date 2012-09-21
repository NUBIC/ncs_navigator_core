require 'uri'

class MergeMailer < ActionMailer::Base
  default :from => NcsNavigatorCore.configuration.mail_from

  register_interceptor SubjectTagger

  def conflict(recipients, merge)
    staff_id = merge.staff_id

    @merge = merge
    @host = URI(NcsNavigatorCore.configuration.base_uri).host
    @fieldwork_id = @merge.fieldwork.try(:fieldwork_id)

    mail :to => recipients,
         :subject => "Merge conflict detected (staff ID: #{staff_id})"
  end
end
