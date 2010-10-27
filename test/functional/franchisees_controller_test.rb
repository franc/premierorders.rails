require 'test_helper'

class FranchiseesControllerTest < ActionController::TestCase
  setup do
    @franchisee = franchisees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:franchisees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create franchisee" do
    assert_difference('Franchisee.count') do
      post :create, :franchisee => @franchisee.attributes
    end

    assert_redirected_to franchisee_path(assigns(:franchisee))
  end

  test "should show franchisee" do
    get :show, :id => @franchisee.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @franchisee.to_param
    assert_response :success
  end

  test "should update franchisee" do
    put :update, :id => @franchisee.to_param, :franchisee => @franchisee.attributes
    assert_redirected_to franchisee_path(assigns(:franchisee))
  end

  test "should destroy franchisee" do
    assert_difference('Franchisee.count', -1) do
      delete :destroy, :id => @franchisee.to_param
    end

    assert_redirected_to franchisees_path
  end
end
