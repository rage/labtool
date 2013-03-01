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
    page.should have_content "not started yet"
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

  it "can not be created with invalid parameters" do
    visit new_course_path
    expect{
      fill_in "course_year", :with => 1
      click_button "Create Course"
    }.to change{Course.all.count}.by(0)
  end

  it "information can be updated and is then shown at courses page" do
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

  it "can be activated/inactivated" do
    visit courses_path
    click_link "make active"

    Course.find(@course.id).active.should be false
    Course.find(@inactive_course.id).active.should be true
  end

  it "week can be advanced" do
    visit course_path(@course.id)
    expect{
      click_button "next week"
    }.to change{Course.find(@course.id).week}.by(1)
    page.should have_content "Week: 2"
  end

  it "code review round can be advanced" do
    visit course_path(@course.id)
    page.should have_content "not started yet"
    click_button "start"
    page.should have_content "round: 1"
    click_button "next round"
    page.should have_content "round: 2"
    click_button "finnish"
    page.should have_content "finished for this course"
    page.should_not have_content "registration: open"
    page.should_not have_content "registration: closed"
  end

  it "code review registration status can be changed" do
    visit course_path(@course.id)
    click_button "start"
    page.should have_content "registration: closed"
    click_button "open registration"
    page.should have_content "registration: open"
    click_button "close registration"
    page.should have_content "registration: closed"
  end

  it "reviews can be made mandatory" do
    visit edit_course_path(@course.id)
    choose "course_mandatory_reviews_1"
    click_button "Update Course"

    page.should have_content "Course was successfully updated."
    page.should have_content "mandatory for all participants"
    Course.find(@course.id).mandatory_reviews.should be true
  end

  describe "if reviewing is mandatory" do
    before do
      visit edit_course_path(@course.id)
      choose "course_mandatory_reviews_1"
      click_button "Update Course"
    end

    it "can be made again voluntary" do
      visit edit_course_path(@course.id)
      choose "course_mandatory_reviews_0"
      click_button "Update Course"

      page.should have_content "Course was successfully updated."
      page.should have_content "on voluntary basis "
      Course.find(@course.id).mandatory_reviews.should be false
    end
  end
end