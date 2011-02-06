require 'test_helper'

class JobItemsControllerTest < ActionController::TestCase
  setup do
    @job_item = job_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_item" do
    assert_difference('JobItem.count') do
      post :create, :job_item => @job_item.attributes
    end

    assert_redirected_to job_item_path(assigns(:job_item))
  end

  test "should show job_item" do
    get :show, :id => @job_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @job_item.to_param
    assert_response :success
  end

  test "should update job_item" do
    put :update, :id => @job_item.to_param, :job_item => @job_item.attributes
    assert_redirected_to job_item_path(assigns(:job_item))
  end

  test "should destroy job_item" do
    assert_difference('JobItem.count', -1) do
      delete :destroy, :id => @job_item.to_param
    end

    assert_redirected_to job_items_path
  end
end
