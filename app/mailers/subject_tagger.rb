class SubjectTagger
  def delivering_email(message)
    unless message.subject =~ /^#{Regexp.escape(origin_tag)}/i
      message.subject = "#{origin_tag} #{message.subject}"
    end
  end

  def origin_tag
    NcsNavigatorCore.configuration.email_prefix
  end
end
