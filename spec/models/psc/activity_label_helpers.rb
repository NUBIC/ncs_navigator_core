module ActivityLabelHelpers
  def al(label)
    Psc::ActivityLabel.from_string(label)
  end
end
