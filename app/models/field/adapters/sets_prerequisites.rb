module Field::Adapters
  module SetsPrerequisites
    def try_to_set(map, *prereqs)
      prereqs.map do |prereq|
        reflection = target.class.reflections[prereq]
        fk_column = reflection.foreign_key
        model = reflection.klass

        if target.send(fk_column).blank?
          public_id = send("#{prereq}_public_id")
          target.send("#{fk_column}=", map.id_for(model, public_id))
        end

        target.send(fk_column)
      end.all?
    end
  end
end
