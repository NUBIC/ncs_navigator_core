module Field::Adapters
  module SetsPrerequisites
    def try_to_set(map, *prereqs)
      prereqs.map do |prereq|
        reflection = target.class.reflections[prereq]
        fk_column = reflection.foreign_key
        model = reflection.klass

        if target.send(fk_column).blank?
          id_map = map[model]
          next false unless id_map

          target.send("#{fk_column}=", id_map[send("#{prereq}_public_id")])
        end

        target.send(fk_column)
      end.all?
    end
  end
end
