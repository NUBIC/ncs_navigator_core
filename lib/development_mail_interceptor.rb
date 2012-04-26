class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "Development- #{message.to} #{message.subject}"
    message.to = "n-shurupova@northwestern.edu"
  end
end