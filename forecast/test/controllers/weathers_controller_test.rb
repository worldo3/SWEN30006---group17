require 'test_helper'

class WeathersControllerTest < ActionController::TestCase
  test "should get location" do
    get :location
    assert_response :success
  end

  test "should get data" do
    get :data
    assert_response :success
  end

  test "should get prediction" do
    get :prediction
    assert_response :success
  end

end
