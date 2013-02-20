require 'spec_helper'

describe "course" do
  before do
    @course = FactoryGirl.create(:course)
    @inactive_course = FactoryGirl.create(:inactive_course)
    @admin = FactoryGirl.create(:admin)
    visit root_path
    click_link "login"
    fill_in "email", :with => @admin.email
    fill_in "password", :with => "foobar"
    click_button "Log in"
  end

  it "are all listed in courses page" do
    visit courses_path
    page.should have_content 'Listing courses'
    Course.all.each do |course|
      page.should have_content course.year
      page.should have_content course.period
    end
  end

  it "can be viewed individually and the details are shown" do
    visit course_path(@course.id)
    page.should have_content "#{@course.year}, #{@course.period}"
    page.should have_content "Week: #{@course.week}"
    page.should have_content "round: #{@course.review_round}"
  end

  it "informaton can be edited"

  it "week can be advanced"

  it "code review status can be changed"

  it "can be deleted"

  describe "with registrations" do

  end
end