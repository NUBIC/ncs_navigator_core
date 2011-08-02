class WelcomeController < ApplicationController
  
  def index
    @dwellings    = DwellingUnit.next_to_process
    @participants = Participant.all
  end
  
end