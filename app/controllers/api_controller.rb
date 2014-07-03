class ApiController < ApplicationController
  def getchart
    render :json => params
  end
end
