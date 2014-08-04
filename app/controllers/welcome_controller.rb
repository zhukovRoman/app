class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index
    @user = User.new(:email => 'podshivalov@kpugs.ru', :password => 'zhrfgjsd', :password_confirmation => 'zhrfgjsd')
    #@user.save!
  end
end
