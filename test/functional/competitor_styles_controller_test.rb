require 'test_helper'

class CompetitorStylesControllerTest < ActionController::TestCase
  setup do
    @competitor_style = competitor_styles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:competitor_styles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create competitor_style" do
    assert_difference('CompetitorStyle.count') do
      post :create, :competitor_style => @competitor_style.attributes
    end

    assert_redirected_to competitor_style_path(assigns(:competitor_style))
  end

  test "should show competitor_style" do
    get :show, :id => @competitor_style.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @competitor_style.to_param
    assert_response :success
  end

  test "should update competitor_style" do
    put :update, :id => @competitor_style.to_param, :competitor_style => @competitor_style.attributes
    assert_redirected_to competitor_style_path(assigns(:competitor_style))
  end

  test "should destroy competitor_style" do
    assert_difference('CompetitorStyle.count', -1) do
      delete :destroy, :id => @competitor_style.to_param
    end

    assert_redirected_to competitor_styles_path
  end
end
