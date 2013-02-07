# -*- coding: utf-8 -*-

RSpec::Matchers.define :be_a_fieldwork_set do
  match do |actual|
    validator = NcsNavigator::Core::Field::JSONValidator.new
    report = validator.validate(actual)
    @errors = report.errors

    report.should_not have_errors
  end

  failure_message_for_should do |actual|
    %Q{
#{actual} has the following validation errors:

#{@errors.map(&:inspect).join("\n")}
    }
  end
end
