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

  it "can be given to a user" do
    visit user_path @user.id

    fill_in "week_feedback_week", :with => 1
    fill_in "week_feedback_points", :with => 2
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    fill_in "week_feedback_hidden_text", :with => "but couldvebeen better"
    click_button "Save"

    page.should have_content "Week feedback was successfully created."
    page.should have_content "week: 1, points: 2"
    page.should have_content "good stuff, boy!"
    page.should have_content "but couldvebeen better"
  end

  it "should have correct parameters until saved and shown" do
    visit user_path @user.id

    fill_in "week_feedback_week", :with => ""
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    expect {
      click_button "Save"
    }.to change { WeekFeedback.all.count }.by(0)

    page.should have_content "Points is not a number"
    page.should have_content "Week is not a number"

    fill_in "week_feedback_week", :with => 1
    fill_in "week_feedback_points", :with => 2
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    click_button "Create Week feedback"

    page.should have_content "Week feedback was successfully created."
    page.should have_content "week: 1, points: 2"
    page.should have_content "good stuff, boy!"
  end

  it "last instructor note is shown on course page" do
    visit user_path @user.id

    fill_in "week_feedback_week", :with => 1
    fill_in "week_feedback_points", :with => 2
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    fill_in "week_feedback_hidden_text", :with => "but couldvebeen better"
    click_button "Save"

    visit user_path @user.id

    fill_in "week_feedback_week", :with => 2
    fill_in "week_feedback_points", :with => 2
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    fill_in "week_feedback_hidden_text", :with => "well done"
    click_button "Save"

    visit course_path @course.id

    page.should have_content "well done"
    page.should_not have_content "couldvebeen"
  end

  describe "when already exists" do
    before do
      visit user_path @user.id

      fill_in "week_feedback_week", :with => 1
      fill_in "week_feedback_points", :with => 2
      fill_in "week_feedback_text", :with => "good stuff, boy!"
      fill_in "week_feedback_hidden_text", :with => "but couldvebeen better"
      click_button "Save"
      fill_in "week_feedback_week", :with => 2
      fill_in "week_feedback_points", :with => 1
      fill_in "week_feedback_text", :with => "not as good as expected"
      click_button "Save"
    end

    it "it can be edited" do
      fill_in "week_feedback_points", :with => 3
      fill_in "week_feedback_text", :with => "better than expected!"
      fill_in "week_feedback_hidden_text", :with => "splendid"
      click_button "Save"

      page.should have_content "Week feedback already exists!"
      page.should have_content "Text should perhaps be merged with the existing!"

      click_button "Update Week feedback"

      page.should have_content "Week feedback was successfully updated"
      page.should have_content "week: 1, points: 3"
      page.should have_content "better than expected!"
      page.should have_content "splendid"
    end

    it "editing should not allow saving invalid parameters" do
      fill_in "week_feedback_week", :with => 1
      click_button "Save"

      fill_in "week_feedback_points", :with => 10
      click_button "Update Week feedback"

      page.should have_content "Points must be less than or equal to 3"
    end

    it "all can be listed" do
      visit week_feedbacks_path
      WeekFeedback.all.each do |r|
        page.should have_content r.text
        page.should have_content r.points
      end
    end

    it "can be deleted" do
      expect {
        page.driver.submit :delete, week_feedback_path(WeekFeedback.first.id), {}
      }.to change { WeekFeedback.count }.by(-1)
    end
  end

  it "a email notification is sent when feedback done and one email checked" do
    visit user_path @user.id

    fill_in "week_feedback_week", :with => 1
    fill_in "week_feedback_points", :with => 2
    fill_in "week_feedback_text", :with => "good stuff, boy!"
    page.check("notify")
    click_button "Save"

    ActionMailer::Base.deliveries.empty?.should == false
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should == "[Ohjelmoinnin harjoitustyo] viikon 1 palaute"
    mail.from.should include @admin.email
    mail.to.should include @user.email
  end
end