require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get getchart" do
    get :getchart
    assert_response :success
  end

end
