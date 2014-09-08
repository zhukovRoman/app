class WelcomeController < ApplicationController
  before_action :change_partName

  def change_partName
    @@partName = "КП УГС"
  end

  def index
    @user = User.new(:email => 'ruslan@mail.test', :password => 'kjlkadfs', :password_confirmation => 'kjlkadfs')
    #@user.save!

  end
end
