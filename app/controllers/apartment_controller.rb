class ApartmentController < ApplicationController
  before_filter :authenticate_user!
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС - Продажи"
  end

  def index2

  end

  def index
    #puts current_user.inspect()
    authorize! :index, self
    render "index2"
  end
end
