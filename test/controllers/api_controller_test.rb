require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get getmsgsbyauthor" do
    get :getmsgsbyauthor
    assert_response :success
  end

  test "should get getmsgsbyrecipient" do
    get :getmsgsbyrecipient
    assert_response :success
  end

  test "should get getpath" do
    get :getpath
    assert_response :success
  end

end
