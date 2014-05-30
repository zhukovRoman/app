require 'test_helper'

class EmployeeControllerTest < ActionController::TestCase
  test "should get vacancies" do
    get :vacancies
    assert_response :success
  end

  test "should get personalInit" do
    get :personalInit
    assert_response :success
  end

end
