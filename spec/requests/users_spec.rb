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

  it "when created, is not registered to any course" do
    visit new_user_path @user.id
    fill_in "user_email", :with => 'own@address.com'
    fill_in "user_forename", :with => "Brian"
    fill_in "user_surename", :with => "McBrain"
    fill_in "user_student_number", :with => "012345678"
    fill_in "user_password", :with => "pw"
    fill_in "user_password_confirmation", :with => "pw"
    click_button "Create User"
    page.should have_content 'User was successfully created.
'
    visit users_path
    page.should have_content "012345678"
    page.should have_content "Brian"
    page.should have_content "McBrain"
    page.should have_content "own@address.com"

    User.last.registrations.count.should == 0
  end

  it "can be made inactivate from the courrent course" do
    visit user_path @user.id
    click_button "Make inactive"

    User.find(@user.id).current_registration.active.should be false
    page.should have_content "Registration status changed"
  end

  it "can be dropped from current course" do
    visit user_path @user.id

    expect {
      click_link "Delete the registration"
    }.to change { @user.registrations.count }.by(-1)
    @course.registrations.count.should == 0
  end

  it "can be deleted" do
    expect {
      page.driver.submit :delete, user_path(@user.id), {}
    }.to change { User.all.count }.by(-1)
  end

  it "deletion does not leave a registration" do
    expect {
      page.driver.submit :delete, user_path(@user.id), {}
    }.to change { Registration.all.count }.by(-1)
  end

  describe "when inactive in current course" do
    before do
      visit user_path @user.id
      click_button "Make inactive"
    end

    it "should be possible to activate the registration" do
      visit user_path @user.id

      click_button "Activate again"

      User.find(@user.id).current_registration.active.should be true
      page.should have_content "Registration status changed"
      elements_with_class('.dropped').size.should == 0
    end

    it "is indicated with a style in course page" do
      visit course_path @course.id

      elements_with_class('.dropped').size.should == 1
      elements_with_class('.dropped').first.should include @user.to_s
    end
  end

  describe "when review points are given to user" do
    before do
      visit user_path @user.id

      choose "registration_review1_1"
      click_button "give points"
    end

    it "those are saved" do
      @user.current_registration.review1.should == 1
    end

    it "those can be edited" do
      visit user_path @user.id
      choose "registration_review1_2"
      click_button "update points"
      @user.current_registration.review1.should == 2
    end
  end

  describe "when week feedback points and review points are given to user" do
    before do
      visit user_path @user.id
      choose "registration_review1_2"
      click_button "give points"
      @user.current_registration.week_feedbacks.create :week => 1, :points => 2
      @user.current_registration.week_feedbacks.create :week => 3, :points => 3
      @user.current_registration.week_feedbacks.create :week => 6, :points => 1
    end

    it "the total is shown on user page" do
      visit user_path @user.id
      page.should have_content "8"
    end

    it "the total is shown on mypage" do
      visit mypage_path
      fill_in "student_number", :with => @user.student_number
      click_button "start!"
      page.should have_content "8"
    end

    it "the total is shown on current course registration list" do
      visit course_path @course.id
      page.should have_content "8"
    end
  end

  def elements_with_class klass
    es = []
    all(klass).each do |e|
      es << e.text
    end
    es
  end
end