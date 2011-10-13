require 'test_helper'

class SubtopicsControllerTest < ActionController::TestCase
  setup do
    @subtopic = subtopics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subtopics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subtopic" do
    assert_difference('Subtopic.count') do
      post :create, :subtopic => @subtopic.attributes
    end

    assert_redirected_to subtopic_path(assigns(:subtopic))
  end

  test "should show subtopic" do
    get :show, :id => @subtopic.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @subtopic.to_param
    assert_response :success
  end

  test "should update subtopic" do
    put :update, :id => @subtopic.to_param, :subtopic => @subtopic.attributes
    assert_redirected_to subtopic_path(assigns(:subtopic))
  end

  test "should destroy subtopic" do
    assert_difference('Subtopic.count', -1) do
      delete :destroy, :id => @subtopic.to_param
    end

    assert_redirected_to subtopics_path
  end
end
