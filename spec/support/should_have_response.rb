require 'case'

triple = Case::Struct.new(:q, :a, :v)

##
# Checks a response set for the presence of a response.  Question and answer
# must be reference identifiers.
RSpec::Matchers.define :have_response do |question, answer, value = Case::Any|
  expected = triple[question, answer, value]

  match do |response_set|
    ok = response_set.responses.any? do |r|
      actual = triple[r.question.reference_identifier, r.answer.reference_identifier, r.value]

      expected === actual
    end

    ok.should be_true
  end

  failure_message_for_should do |response_set|
    q = expected.q
    a = expected.a
    v = expected.v

    "Did not find response qref=#{q}, aref=#{a}, value=#{v} in response set"
  end
end
