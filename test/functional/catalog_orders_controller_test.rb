require 'test_helper'

class CatalogOrdersControllerTest < ActionController::TestCase
  setup do
    @catalog_order = catalog_orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:catalog_orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create catalog_order" do
    assert_difference('CatalogOrder.count') do
      post :create, :catalog_order => @catalog_order.attributes
    end

    assert_redirected_to catalog_order_path(assigns(:catalog_order))
  end

  test "should show catalog_order" do
    get :show, :id => @catalog_order.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @catalog_order.to_param
    assert_response :success
  end

  test "should update catalog_order" do
    put :update, :id => @catalog_order.to_param, :catalog_order => @catalog_order.attributes
    assert_redirected_to catalog_order_path(assigns(:catalog_order))
  end

  test "should destroy catalog_order" do
    assert_difference('CatalogOrder.count', -1) do
      delete :destroy, :id => @catalog_order.to_param
    end

    assert_redirected_to catalog_orders_path
  end
end
