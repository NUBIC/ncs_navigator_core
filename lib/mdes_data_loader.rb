require 'ncs_navigator/mdes'

module MdesDataLoader
  def self.load_codes_from_schema
    mdes = NcsNavigatorCore.mdes
    counter = 0
    NcsCode.transaction do
      mdes.types.each do |typ|
        next if typ.name.blank?

        list_name = typ.name.upcase # this is the code list name

        if typ.code_list
          typ.code_list.each do |code_list_entry|
            ncs_code = NcsCode.find(:first,
              :conditions => { :list_name => list_name, :local_code => code_list_entry.value })
            if ncs_code.blank?
              counter += 1
              NcsCode.create(
                :list_name => list_name,
                :local_code => code_list_entry.value,
                :display_text => code_list_entry.label)
            end
          end
        end
      end
    end
    puts "Created #{counter} new NcsCode#{'s' if counter != 1} from MDES #{mdes.specification_version}."
  end
end
