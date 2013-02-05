require 'spec_helper'

module NcsNavigator::Core
  describe JSONValidator do
    let(:v) { JSONValidator.new }

    let(:noref_schema) do
      %Q{
        {
            "$schema": "http://json-schema.org/draft-03/schema#", 
            "properties": {
                "foo": {
                    "required": true, 
                    "type": "string"
                }
            }
        }
      }
    end

    let(:noref_valid_json) do
      %Q{
        { "foo": "bar" }
      }
    end

    let(:noref_invalid_json) do
      %Q{
        {}
      }
    end

    describe '#validate' do
      describe 'using a schema without references' do
        before do
          v.schema = noref_schema
        end

        it 'returns true for JSON that satisfies the schema' do
          v.validate(noref_valid_json).should be_true
        end

        it 'returns false for JSON that does not satisfy the schema' do
          v.validate(noref_invalid_json).should be_false
        end
      end
    end
  end
end
