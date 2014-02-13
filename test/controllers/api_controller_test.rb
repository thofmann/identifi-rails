require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get getpacketsbyauthor" do
    get :getpacketsbyauthor
    assert_response :success
  end

  test "should get getpacketsbyrecipient" do
    get :getpacketsbyrecipient
    assert_response :success
  end

  test "should get getpath" do
    get :getpath
    assert_response :success
  end

end
