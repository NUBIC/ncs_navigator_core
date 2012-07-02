# -*- coding: utf-8 -*-


class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods

  default_scope :order => "display_order ASC, id ASC"

end

