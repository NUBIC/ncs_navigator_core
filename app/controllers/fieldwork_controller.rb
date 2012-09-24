# -*- coding: utf-8 -*-
class FieldworkController < ApplicationController
  def index
    @fieldworks = Fieldwork.for_report.paginate(:page => params[:page], :per_page => 20)
  end
end
