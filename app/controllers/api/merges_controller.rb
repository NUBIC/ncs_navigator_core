# -*- coding: utf-8 -*-

class Api::MergesController < ApplicationController
  respond_to :json

  def show
    respond_with Merge.find(params['id'])
  end
end
