require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes
  class NcsCodedAttribute
    attr_reader :attribute_name, :list_name, :model_class

    def initialize(model_class, attribute_name, list_name)
      @list_name = list_name.upcase
      @attribute_name = attribute_name.to_sym
      @model_class = model_class

      unless model_class.ancestors.include?(NcsCodedAttributeValueHelpers)
        model_class.send(:include, NcsCodedAttributeValueHelpers)
      end
      model_class.send(:include, extensions_module)
    end

    def code_list
      NcsCode.where(:list_name => list_name)
    end

    def foreign_key_name
      @foreign_key ||= "#{attribute_name}_code"
    end

    def foreign_key_getter
      @foreign_key_getter ||= foreign_key_name
    end

    def foreign_key_setter
      @foreign_key_setter ||= "#{foreign_key_getter}="
    end

    def instance_variable_name
      "@#{attribute_name}"
    end

    protected

    def extensions_module
      nca = self
      @extensions_module ||= Module.new do
        define_method(nca.attribute_name) do
          get_ncs_code(nca)
        end

        define_method("#{nca.attribute_name}=") do |value|
          set_ncs_code(nca, value)
        end

        define_method(nca.foreign_key_setter) do |value|
          super(value).tap { instance_variable_set(nca.instance_variable_name, nil) }
        end
      end
    end

    module NcsCodedAttributeValueHelpers
      def get_ncs_code(ncs_coded_attribute)
        if curr_val = instance_variable_get(ncs_coded_attribute.instance_variable_name)
          curr_val
        elsif curr_fk = send(ncs_coded_attribute.foreign_key_getter)
          ncs_code = NcsCode.for_list_name_and_local_code(ncs_coded_attribute.list_name, curr_fk)
          instance_variable_set(ncs_coded_attribute.instance_variable_name, ncs_code)
          ncs_code
        end
      end

      def set_ncs_code(ncs_coded_attribute, ncs_code_value)
        instance_var = ncs_coded_attribute.instance_variable_name
        fk_setter = ncs_coded_attribute.foreign_key_setter

        case ncs_code_value
        when nil
          send(fk_setter, nil)
          instance_variable_set(instance_var, nil)
        when NcsCode
          send(fk_setter, ncs_code_value.local_code)
          instance_variable_set(instance_var, ncs_code_value)
        when Fixnum
          send(fk_setter, ncs_code_value)
          instance_variable_set(instance_var, nil) # to force reload
        else
          fail "Cannot resolve an NcsCode from #{ncs_code_value.inspect} (#{ncs_code_value.class})"
        end
      end
    end
  end
end
