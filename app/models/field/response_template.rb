module Field
  ##
  # Templates for Responses for Field.
  #
  # This template names:
  #
  # - a survey by its API ID
  # - a question in the survey by its reference identifier
  # - an answer in the survey, also by its reference identifier
  # - a preset value, if appropriate
  #
  # When instantiating a response set for the named survey, field clients
  # should prepopulate that response set with one response per template.
  #
  # ResponseTemplates are typically generated from {EventTemplateGenerator}.
  class ResponseTemplate < Struct.new(:aref, :qref, :survey_id, :value)
  end
end
