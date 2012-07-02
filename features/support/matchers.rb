

RSpec::Matchers.define :be_a_fieldwork_set do
  match do |actual|
    schema_file = "#{Rails.root}/vendor/ncs_navigator_schema/fieldwork_schema.json"

    unless File.exists?(schema_file)
      raise "#{schema_file} not found; did you initialize this project's submodules?"
    end

    schema = JSON.parse(File.read(schema_file))
    data = JSON.parse(actual)
    @errors = JSON::Validator.fully_validate(schema, data)

    @errors.should == []
  end

  failure_message_for_should do |actual|
    %Q{
#{actual} has the following validation errors:

#{@errors.join("\n")}
    }
  end
end