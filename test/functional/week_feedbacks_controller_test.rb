require 'test_helper'

class WeekFeedbacksControllerTest < ActionController::TestCase
  setup do
    @week_feedback = week_feedbacks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:week_feedbacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create week_feedback" do
    assert_difference('WeekFeedback.count') do
      post :create, week_feedback: { points: @week_feedback.points, text: @week_feedback.text }
    end

    assert_redirected_to week_feedback_path(assigns(:week_feedback))
  end

  test "should show week_feedback" do
    get :show, id: @week_feedback
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @week_feedback
    assert_response :success
  end

  test "should update week_feedback" do
    put :update, id: @week_feedback, week_feedback: { points: @week_feedback.points, text: @week_feedback.text }
    assert_redirected_to week_feedback_path(assigns(:week_feedback))
  end

  test "should destroy week_feedback" do
    assert_difference('WeekFeedback.count', -1) do
      delete :destroy, id: @week_feedback
    end

    assert_redirected_to week_feedbacks_path
  end
end
