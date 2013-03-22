require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes
  class NcsCodedAttribute
    attr_reader :attribute_name, :list_name

    def initialize(model_class, attribute_name, list_name)
      @list_name = list_name.upcase
      @attribute_name = attribute_name.to_sym
      belongs_to!(model_class)
    end

    def foreign_key
      @foreign_key ||= "#{attribute_name}_code".to_sym
    end

    def belongs_to!(model)
      model.belongs_to(attribute_name,
        :conditions => "list_name = '#{list_name}'",
        :foreign_key => foreign_key,
        :class_name => 'NcsCode',
        :primary_key => :local_code)
    end

    def code_list
      NcsCode.where(:list_name => list_name)
    end
  end
end
