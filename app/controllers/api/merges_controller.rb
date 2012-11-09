# -*- coding: utf-8 -*-

class Api::MergesController < ApiController
  def show
    respond_with Merge.find(params['id'])
  end
end
