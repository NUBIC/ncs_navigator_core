module ParticipantsHelper
  
  def switch_arm_message(participant)
    msg = "Switch from Low Intensity to High Intensity"
    msg = "Switch from High Intensity to Low Intensity" if participant.high_intensity
    msg
  end
end