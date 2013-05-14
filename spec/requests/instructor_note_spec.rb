require 'spec_helper'

describe "instructor note" do
  before do
    @course = FactoryGirl.create(:course)
    @inactive_course = FactoryGirl.create(:inactive_course)
    @user = FactoryGirl.create(:user)
    @registration = FactoryGirl.create(:registration, :user => @user, :course => @course)
    @admin = FactoryGirl.create(:admin)
    visit root_path
    click_link "login"
    fill_in "email", :with => @admin.email
    fill_in "password", :with => "foobar"
    click_button "Log in"
  end

  describe "when given" do
    before do
      visit user_path @user.id

      fill_in "hidden_text", :with => "scheisse"
      click_button "Save the instructor only note"
    end

    it "is visible in user page" do
      visit user_path @user.id

      page.should have_content "scheisse"
    end

    it "is visible in course page" do
      visit course_path @course.id

      page.should have_content "scheisse"
    end

    it "is not visible to student" do
      visit mypage_path
      fill_in "student_number", :with => @user.student_number
      click_button "start!"

      page.should_not have_content "scheisse"
    end
  end

end
