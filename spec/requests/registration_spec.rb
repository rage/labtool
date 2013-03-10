require 'spec_helper'

describe "registration" do
  before do
    @course = FactoryGirl.create(:course)
  end

  it "can be navigated using the link" do
    visit root_path
    click_link "register"
    current_path.should == register_path
  end

  describe "when form is properly filled" do
    before do
      visit root_path
      click_link "register"
      fill_in "user_forename", :with => "Jim"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "jim@example.com"
      fill_in "user_student_number", :with => "012345678"
      fill_in "registration_topic", :with => "beermemo"
      fill_in "registration_repository", :with => "https://github.com/mluukkai/beermemo/"
    end

    it "user is directed to mypage which show the data correctly" do
      click_button "Create Registration"
      page.should have_content "Jim Doe"
      page.should have_content "Current work"
      page.should have_content "Code reviews"
      page.should have_content "beermemo"
      page.should have_content "https://github.com/mluukkai/beermemo/"
    end

    it "creates a registration for the course" do
      expect {
        click_button "Create Registration"
      }.to change { @course.registrations.count }.by(1)
    end

    it "creates a new user" do
      expect {
        click_button "Create Registration"
      }.to change { User.count }.by(1)
    end

  end

  describe "when a user is registered" do
    before do
      visit root_path
      click_link "register"
      fill_in "user_forename", :with => "Jim"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "jim@example.com"
      fill_in "user_student_number", :with => "012345678"
      fill_in "registration_topic", :with => "beermemo"
      fill_in "registration_repository", :with => "https://github.com/mluukkai/beermemo/"
      click_button "Create Registration"
    end

    it "second registration to the same course fails" do
      visit root_path
      click_link "register"
      fill_in "user_forename", :with => "Jim"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "jim@example.com"
      fill_in "user_student_number", :with => "012345678"
      fill_in "registration_topic", :with => "watermemo"
      fill_in "registration_repository", :with => "https://github.com/mluukkai/watermemo/"

      expect {
        click_button "Create Registration"
      }.to change { @course.registrations.count }.by(0)

      page.should have_content "You have already registered for the current course!"
      page.should have_content "Jim Doe"
      page.should have_content "beermemo"
    end

    it "registrations by another student increases the amount of registrations for the course" do
      visit root_path
      click_link "register"
      fill_in "user_forename", :with => "Joe"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "joe@example.com"
      fill_in "user_student_number", :with => "012345679"
      fill_in "registration_topic", :with => "watermemo"
      fill_in "registration_repository", :with => "https://github.com/mluukkai/water/"

       expect {
         click_button "Create Registration"
       }.to change { @course.registrations.count }.by(1)
     end

    describe "second registration by the same use to another course should not increase amount of users" do
      before do
        @course.update_attributes :active => false
        @course2 = FactoryGirl.create(:inactive_course, :active => true)
        visit root_path
        click_link "register"
        fill_in "user_forename", :with => "Jim"
        fill_in "user_surename", :with => "Doe"
        fill_in "user_email", :with => "jim@example.com"
        fill_in "user_student_number", :with => "012345678"
        fill_in "registration_topic", :with => "watermemo"
        fill_in "registration_repository", :with => "https://github.com/mluukkai/watermemo/"

        expect {
          click_button "Create Registration"
        }.to change { User.count }.by(0)
      end

    end

    describe "administrator" do
      before do
        @admin = FactoryGirl.create(:admin)
        visit root_path
        click_link "login"
        fill_in "email", :with => @admin.email
        fill_in "password", :with => "foobar"
        click_button "Log in"
      end

      it "can see registrations" do
        click_link 'registrations'

        page.should have_content "Listing registrations"
        page.should have_content "Jim Doe"
        page.should have_content "beermemo"
        page.should have_content "https://github.com/mluukkai/beermemo/"
      end

      it "can view a registration" do
        registration = Registration.first
        visit registration_path(registration.id)
        page.should have_content "User: #{registration.user}"
        page.should have_content "Topic: #{registration.topic}"
        page.should have_content "Repository: #{registration.repository}"
      end

      it "can edit a registration" do
        registration = Registration.first
        visit registration_path(registration.id)
        click_link "Edit"

        page.should have_content "Editing registration of #{registration.user}"

        fill_in "registration_topic", :with => "Whitebeermemo"
        click_button "Update Registration"

        page.should have_content "Registration was successfully updated"
        page.should have_content registration.user
        page.should have_content "Whitebeermemo"
        page.should have_content registration.repository
      end

      it "can delete a registration" do
        click_link 'registrations'
        expect {
          click_link "Destroy"
        }.to change { @course.registrations.count }.by(-1)
      end

      it "is redirected back to reviews page with a proper notice after deleting a registration" do
        click_link 'registrations'
        click_link "Destroy"
        page.should have_content "Listing registrations"
        page.should have_content "Registration destroyed"
        page.should_not have_content "Jim Doe"
        page.should_not have_content "beermemo"
        page.should_not have_content "https://github.com/mluukkai/beermemo/"
      end
    end

  end

  describe "when student number is not properly filled" do
    before do
      visit root_path
      click_link "register"
      fill_in "user_forename", :with => "Jim"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "jim@example.com"
      fill_in "registration_topic", :with => "beermemo"
      fill_in "registration_repository", :with => "https://github.com/mluukkai/beermemo/"
      fill_in "user_student_number", :with => "01234567"
    end

    it "user is directed to edit registration page and error message is shown" do
      click_button "Create Registration"
      page.should have_content "Editing registration"
      page.should have_content "should start with 0 and be followed by 8 digits"
      find_field("user_email").value.should == "jim@example.com"
    end

    it "by correcting it, registration is created" do
      fill_in "user_student_number", :with => "012345678"
      click_button "Create Registration"

      page.should have_content "Jim Doe"
      page.should have_content "Current work"
      page.should have_content "Code reviews"
      page.should have_content "beermemo"
      page.should have_content "https://github.com/mluukkai/beermemo/"
    end
  end

  describe "when repository name is not properly filled" do
    before do
      visit root_path
      click_link "register"
      fill_in "user_student_number", :with => "012345678"
      fill_in "user_forename", :with => "Jim"
      fill_in "user_surename", :with => "Doe"
      fill_in "user_email", :with => "jim@example.com"
      fill_in "registration_topic", :with => "beermemo"
      fill_in "registration_repository", :with => "http://example.com"
    end

    it "user is directed to edit registration page and error message is shown" do
      click_button "Create Registration"
      page.should have_content "Editing registration"
      page.should have_content "copy/paste your repo address here from browser address line"

      find_field("user_email").value.should == "jim@example.com"
      find_field("registration_repository").value.should == "http://example.com"
    end

    it "by correcting it, registration is created" do
      fill_in "registration_repository", :with => "https://github.com/mluukkai/beermemo/"
      click_button "Create Registration"

      page.should have_content "Jim Doe"
      page.should have_content "Current work"
      page.should have_content "Code reviews"
      page.should have_content "beermemo"
      page.should have_content "https://github.com/mluukkai/beermemo/"
    end
  end

end
