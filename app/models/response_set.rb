class ResponseSet < ActiveRecord::Base
  include Surveyor::Models::ResponseSetMethods
  belongs_to :person, :foreign_key => :id, :class_name => 'Person', :primary_key => :user_id
end
