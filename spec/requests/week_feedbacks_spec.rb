require 'spec_helper'

describe "week feedback" do
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
end