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

  it "can be created and is then shown at courses page" do
    visit new_course_path
    fill_in "course_year", :with => 2100
    fill_in "course_period", :with => "periodi X"
    fill_in "course_week", :with => 0
    click_button "Create Course"

    visit courses_path
    page.should have_content "2100"
    page.should have_content "periodi X"
  end

  it "informaton can be updated and is then shown at courses page" do
    visit edit_course_path(@course.id)
    fill_in "course_period", :with => "periodi V"
    click_button "Update Course"

    page.should have_content "Course was successfully updated."

    visit courses_path
    page.should have_content "periodi V"
  end

  it "can be deleted after which user is redirected to courses page and a proper notification is shown" do
    visit courses_path
    expect{ first(:link, "Destroy").click }.to change { Course.all.count }.by(-1)
    page.should have_content 'Listing courses'
    page.should have_content 'Course was destroyed'
  end

  it "week can be advanced"

  it "code review status can be changed"

  it "can be activated/inactivated"

  describe "with registrations" do

  end
end