require 'test_helper'

class FranchiseeAddressesControllerTest < ActionController::TestCase
  setup do
    @franchisee_address = franchisee_addresses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:franchisee_addresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create franchisee_address" do
    assert_difference('FranchiseeAddress.count') do
      post :create, :franchisee_address => @franchisee_address.attributes
    end

    assert_redirected_to franchisee_address_path(assigns(:franchisee_address))
  end

  test "should show franchisee_address" do
    get :show, :id => @franchisee_address.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @franchisee_address.to_param
    assert_response :success
  end

  test "should update franchisee_address" do
    put :update, :id => @franchisee_address.to_param, :franchisee_address => @franchisee_address.attributes
    assert_redirected_to franchisee_address_path(assigns(:franchisee_address))
  end

  test "should destroy franchisee_address" do
    assert_difference('FranchiseeAddress.count', -1) do
      delete :destroy, :id => @franchisee_address.to_param
    end

    assert_redirected_to franchisee_addresses_path
  end
end
