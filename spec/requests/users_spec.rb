require 'spec_helper'

describe "user" do
  before do
    @course = FactoryGirl.create(:course)
    @admin = FactoryGirl.create(:admin)
    @user = FactoryGirl.create(:user)
    @registration = FactoryGirl.create(:registration, :user => @user, :course => @course)
    visit root_path
    click_link "login"
    fill_in "email", :with => @admin.email
    fill_in "password", :with => "foobar"
    click_button "Log in"
  end

  it "are all listed in users page" do
    visit users_path
    page.should have_content 'Listing users'
    User.all.each do |user|
      page.should have_content user.student_number
      page.should have_content user.forename
      page.should have_content user.email
    end
  end

  it "information is shown on personal page" do
    visit user_path @user.id

    page.should have_content @user.student_number
    page.should have_content @user.surename
    page.should have_content "Current work"
    page.should have_content @registration.repository
    page.should have_content @registration.topic
  end

  it "information can be edited" do
    visit edit_user_path @user.id
    fill_in "user_email", :with => 'new@address.com'
    fill_in "user_forename", :with => "Brian"
    click_button "Update User"

    page.should have_content 'User was successfully updated.'
    page.should have_content @user.student_number
    page.should have_content 'Brian'
    page.should have_content 'new@address.com'
    page.should have_content @registration.repository
    page.should have_content @registration.topic
  end

  it "creating new"

  it "delete"

  it "can be dropped from current course"
end