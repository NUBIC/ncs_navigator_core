class Answer < ActiveRecord::Base
  include NcsNavigator::Core::Surveyor::HasPublicId
  include Surveyor::Models::AnswerMethods
end
