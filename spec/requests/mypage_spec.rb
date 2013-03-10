require 'spec_helper'

describe "mypage" do
  before do
    @user = FactoryGirl.create(:user)
    @course = FactoryGirl.create(:course)
  end

  it "is visible by anybody" do
    visit mypage_path
    page.should have_content 'Enter your student number to see your course feedback'
  end

  describe "of an existing user" do
    it "when navigated shows the user email and student number" do
      visit mypage_path
      fill_in "student_number", :with => '000000001'
      click_button "start!"

      page.should have_content "Email: #{@user.email}"
      page.should have_content "Student number: #{@user.student_number}"
    end

    it "redirects back to mypage if user tries to access page directly without filling form" do
      visit "#{mypage_path}/#{@user.id}"
      page.should have_content 'Enter your student number to see your course feedback'
    end
  end

  describe "of a nonexisting user"  do
    it "when navigated, redirects back to frontpage" do
      visit mypage_path
      fill_in "student_number", :with => '012345678'
      click_button "start!"
      page.should have_content 'Enter your student number to see your course feedback'
    end
  end

  describe "when user registered in course" do
    before do
      @registration = FactoryGirl.create(:registration, :user => @user, :course => @course)
      visit mypage_path
      fill_in "student_number", :with => '000000001'
      click_button "start!"
    end

    it "the userpage shows registration information" do
      page.should have_content "Current work"
      page.should have_content "Code reviews"
      page.should have_content @registration.topic
      page.should have_content @registration.repository
    end

    it "it is possible to start editing own information" do
      click_link "Edit your information"
      page.should have_content "Editing your information"
    end

    describe "and navigated to editing to own information" do
      before do
        click_link "Edit your information"
      end

      it "is possible to change the repository address" do
        fill_in "user_registration_repository", :with => 'https://github.com/mluukkai/labtool/'
        click_button "Make changes"

        page.should have_content "Current work"
        page.should have_content "Code reviews"
        page.should have_content @registration.topic
        page.should have_content 'https://github.com/mluukkai/labtool/'
      end
    end
  end

end
