require 'spec_helper'

describe "login" do
  before do
    @course = FactoryGirl.create(:course)
  end

  it "without doing one, only default navigation links visible" do
    visit root_path

    ['register', 'my page', 'login'].each do |link|
      page.should have_link(link)
    end

    [ 'registrations' 'peer reviews' 'current course' 'courses' 'users' 'logout'].each do |link|
      page.should_not have_link(link)
    end
  end

  describe "when done" do

    before do
      @admin = FactoryGirl.create(:admin)
      @user = FactoryGirl.create(:user)
    end

    it "succesfully by admin, should enable navigation links and take to active course page" do
      visit root_path
      click_link "login"
      fill_in "email", :with => @admin.email
      fill_in "password", :with => "foobar"
      click_button "Log in"

      ['register', 'my page', 'registrations', 'peer reviews', 'current course', 'courses', 'users','logout'].each do |link|
        page.should have_link(link)
      end

      [ 'login'].each do |link|
        page.should_not have_link(link)
      end

      current_path.should == course_path(@course)
    end

    it "unsuccesfully by admin, should not enable links and takes back to login page" do
      visit root_path
      click_link "login"
      fill_in "email", :with => @admin.email
      fill_in "password", :with => "wrong"
      click_button "Log in"

      ['register', 'my page', 'login'].each do |link|
        page.should have_link(link)
      end

      [ 'registrations' 'peer reviews' 'current course' 'courses' 'users' 'logout'].each do |link|
        page.should_not have_link(link)
      end

      current_path.should == login_path
    end

    describe "logging out" do
      before do
        visit root_path
        click_link "login"
        fill_in "email", :with => @admin.email
        fill_in "password", :with => "foobar"
        click_button "Log in"
      end

      it "should disable logged in users navigation links and redirect to root path" do
        click_link "logout"

        ['register', 'my page', 'login'].each do |link|
          page.should have_link(link)
        end

        [ 'registrations' 'peer reviews' 'current course' 'courses' 'users' 'logout'].each do |link|
          page.should_not have_link(link)
        end

        current_path.should == root_path
      end

    end
  end

end