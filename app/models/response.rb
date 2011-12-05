class Response < ActiveRecord::Base
  include Surveyor::Models::ResponseMethods

  def reportable_value
    case answer.response_class
    when 'answer'
      self.answer.reference_identifier.sub(/neg_/, '-')
    when 'string'
      self.string_value
    when 'integer'
      self.integer_value
    when 'datetime'
      self.datetime_value.iso8601[0,19]
    else
      fail "Unsupported response class in #reportable_value: #{answer.response_class}"
    end
  end
end
