require 'test_helper'

class ProductionBatchesControllerTest < ActionController::TestCase
  setup do
    @production_batch = production_batches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:production_batches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create production_batch" do
    assert_difference('ProductionBatch.count') do
      post :create, :production_batch => @production_batch.attributes
    end

    assert_redirected_to production_batch_path(assigns(:production_batch))
  end

  test "should show production_batch" do
    get :show, :id => @production_batch.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @production_batch.to_param
    assert_response :success
  end

  test "should update production_batch" do
    put :update, :id => @production_batch.to_param, :production_batch => @production_batch.attributes
    assert_redirected_to production_batch_path(assigns(:production_batch))
  end

  test "should destroy production_batch" do
    assert_difference('ProductionBatch.count', -1) do
      delete :destroy, :id => @production_batch.to_param
    end

    assert_redirected_to production_batches_path
  end
end
