class MergeMailer < ActionMailer::Base
  default :from => NcsNavigatorCore.configuration.mail_from

  register_interceptor SubjectTagger

  def conflict(recipients, merge)
    staff_id = merge.staff_id

    @merge = merge

    mail :to => recipients,
         :subject => "Merge conflict detected (staff ID: #{staff_id})"
  end
end
