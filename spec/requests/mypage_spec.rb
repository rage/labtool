require 'spec_helper'

describe "mypage" do
  before do
    @user = user = FactoryGirl.create(:user)
  end

  describe "frontpage" do
    it "is visible by anybody" do
      visit mypage_path
      page.should have_content 'Enter your student number to give a peer review'
    end
  end

  describe "an existing userpage" do
    it "when navigated shows the user email and student number" do
      visit mypage_path
      fill_in "student_number", :with => '1'
      click_button "start!"
      page.should have_content "Email: #{@user.email}"
      page.should have_content "Student number: #{@user.student_number}"
    end
  end

  describe "an non existing userpage" do
    it "when navigated, redirects back to frontpage" do
      visit mypage_path
      fill_in "student_number", :with => '2'
      click_button "start!"
      page.should have_content 'Enter your student number to give a peer review'
    end
  end

  it "ei tehdasta" do
    User.count.should == 1
  end

end
