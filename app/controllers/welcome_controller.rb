class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index
    @user = User.new(:email => 'shevlyagin@terra-auri.ru', :password => 'udfso4ihw', :password_confirmation => 'udfso4ihw')
    #@user.save!

  end
end
