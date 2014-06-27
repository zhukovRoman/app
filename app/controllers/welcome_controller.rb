class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index
    @user = User.new(:email => 'zhrovl@gmail.com', :password => 'pass123', :password_confirmation => 'pass123')
    #@user.save!
  end
end
