require 'spec_helper'

describe "peer review" do
  before do
    @course = FactoryGirl.create(:course, :review_round => 1, :state => 1)
    @admin = FactoryGirl.create(:admin)
    visit root_path
    click_link "login"
    fill_in "email", :with => @admin.email
    fill_in "password", :with => "foobar"
    click_button "Log in"
  end

  describe "when all students participate to first review round" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @students = [@user1, @user2, @user3]
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => true)

      visit peer_reviews_path
    end

    it "at start no one has assigned reviews" do
      page.should have_content "Assign peer reviews for students"
      page.should have_content "Course: #{@course}"
      page.should have_content "review round 1, registration open"

      @students.each { |s|
        page.should have_content s.to_s
      }

      elements_with_class('.review-assigned').size.should == 0
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 0
      elements_with_class('.many-reviewers-assigned').size.should == 0
    end

    it "review assignment generation assigns one review and reviewee for each participant" do
      (1..5).each do
        click_button "generate default review assignments"

        student_names = @students.map(&:to_s)

        elements_with_class('.review-assigned').size.should == 3
        elements_with_class('.reviewer-assigned').size.should == 3
        elements_with_class('.review-assigned').should =~ student_names
        elements_with_class('.reviewer-assigned').should =~ student_names

        elements_with_class('.many-reviews-assigned').size.should == 0
        elements_with_class('.many-reviewers-assigned').size.should == 0

        review_assignment_should_be_good_for_round 1
      end
    end

    it "review assignments are reset properly" do
      click_button "generate default review assignments"
      click_button "reset review assignments"

      elements_with_class('.review-assigned').size.should == 0
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 0
      elements_with_class('.many-reviewers-assigned').size.should == 0
    end

    it "a review assignment can be manually toggled on" do
      expect {
        find(button_for(@user1, @user2)).click_button('review')
      }.to change { PeerReview.all.count }.by(1)

      visit peer_reviews_path

      elements_with_class('.review-assigned').size.should == 1
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 1
      elements_with_class('.many-reviewers-assigned').size.should == 0
    end

    it "a review assignment can be manually toggled of" do
      find(button_for(@user1, @user2)).click_button('review')

      visit peer_reviews_path

      expect {
        find(button_for(@user1, @user2)).click_button('cancel')
      }.to change { PeerReview.all.count }.by(-1)

      visit peer_reviews_path

      elements_with_class('.review-assigned').size.should == 0
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 0
      elements_with_class('.many-reviewers-assigned').size.should == 0
    end

    it "incorrect assignment is visualized" do
      find(button_for(@user1, @user2)).click_button('review')

      visit peer_reviews_path

      find(button_for(@user1, @user3)).click_button('review')

      visit peer_reviews_path

      find(button_for(@user2, @user3)).click_button('review')

      visit peer_reviews_path

      elements_with_class('.many-reviews-assigned').size.should == 1
      elements_with_class('.many-reviewers-assigned').size.should == 1
    end

    describe "when registration closed" do
      before do
        @course.update_attributes(:state => 0)
      end

      it "assignment is shown on user's page when " do
        find(button_for(@user1, @user2)).click_button('review')

        visit mypage_path
        fill_in "student_number", :with => @user1.student_number
        click_button "start!"

        page.should have_content "Code to review"
        page.should have_content @user2.current_registration.repository
        page.should_not have_content "Your reviewer"
        page.should have_content "Nobody assigned to review your code yet"

        visit mypage_path
        fill_in "student_number", :with => @user2.student_number
        click_button "start!"

        page.should have_content "Your reviewer"
        page.should have_content "No code assigned to you for review yet"
        page.should_not have_content "Code to review"
        page.should have_content @user1.current_registration.repository
        page.should have_content "not done yet "
      end

      it "assignment can be marked as done by user" do
        find(button_for(@user1, @user2)).click_button('review')

        visit mypage_path
        fill_in "student_number", :with => @user1.student_number
        click_button "start!"

        click_button "click when done"

        visit mypage_path
        fill_in "student_number", :with => @user2.student_number
        click_button "start!"

        page.should have_content "Your reviewer"
        page.should have_content "No code assigned to you for review yet"
        page.should_not have_content "Code to review"
        page.should have_content @user1.current_registration.repository
        page.should_not have_content "not done yet"
        page.should have_content "ready"
      end
    end

  end

  describe "second review round" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @students = [@user1, @user2, @user3]
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => true, :participate_review2 => true)

      visit peer_reviews_path
      click_button "generate default review assignments"
      @course.update_attributes(:review_round => 2)
      visit peer_reviews_path
    end

    it "at start no one has assigned reviews" do
      page.should have_content "Assign peer reviews for students"
      page.should have_content "Course: #{@course}"
      page.should have_content "review round 2, registration open"

      @students.each { |s|
        page.should have_content s.to_s
      }

      elements_with_class('.review-assigned').size.should == 0
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 0
      elements_with_class('.many-reviewers-assigned').size.should == 0
    end

    it "review assignment generation assigns one review and reviewee for each participant" do
      (1..5).each do
        click_button "generate default review assignments"

        student_names = @students.map(&:to_s)

        elements_with_class('.review-assigned').size.should == 3
        elements_with_class('.reviewer-assigned').size.should == 3
        elements_with_class('.review-assigned').should =~ student_names
        elements_with_class('.reviewer-assigned').should =~ student_names

        elements_with_class('.many-reviews-assigned').size.should == 0
        elements_with_class('.many-reviewers-assigned').size.should == 0

        review_assignment_should_be_good_for_round 2
      end
    end

    it "does not contain same assigned pair as in the first round" do
      (1..5).each do
        click_button "generate default review assignments"
        review_assignments_should_not_collide_for_rounds
      end
    end

    it "if a student is made inactive, the first round reviews are not removed" do
      visit user_path @user1.id
      expect{
        click_button "Make inactive"
      }.to change{PeerReview.select { |p| p.round==1 }.count}.by(0)
    end
  end

  describe "if not all do not participate" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => false, :participate_review2 => false)

      visit peer_reviews_path
      click_button "generate default review assignments"
    end

    it "only the participating ones will get reviews and reviewers" do
      page.should have_content "Assign peer reviews for students"
      page.should have_content "Course: #{@course}"
      page.should have_content "review round 1, registration open"

      page.should have_content @user1.to_s
      page.should have_content @user2.to_s
      page.should_not have_content @user3.to_s

      elements_with_class('.review-assigned').size.should == 2
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 2
      elements_with_class('.many-reviewers-assigned').size.should == 0

      student_ids = [@user1.id, @user2.id]
      reviewers = PeerReview.select { |p| p.round==1 }.map { |p| p.reviewer.user.id }
      revieweds = PeerReview.select { |p| p.round==1 }.map { |p| p.reviewed.user.id }

      (reviewers.sort == student_ids.sort).should be true
      (revieweds.sort == student_ids.sort).should be true
    end
  end

  describe "if an review assignment exists and user is marked as inactive" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => true, :participate_review2 => true)

      visit peer_reviews_path
      click_button "generate default review assignments"

      visit user_path @user1.id
      click_button "Make inactive"
    end

    it "his peer review assignments are deleted" do
      current_reviews = PeerReview.select { |p| p.round = @course.review_round }
      current_reviews.map(&:reviewer_id).should_not include @user1.current_registration.id
      current_reviews.map(&:reviewed_id).should_not include @user1.current_registration.id
    end
  end

  describe "if student is marked as inactive" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => true, :participate_review2 => true)

      visit user_path @user1.id
      click_button "Make inactive"
    end

    it "he is not shown at peer review assignment page" do
      visit peer_reviews_path

      page.should_not have_content @user1.to_s
    end

    it "no reviews are assigned to him" do
      visit peer_reviews_path
      click_button "generate default review assignments"

      current_reviews = PeerReview.select { |p| p.round = @course.review_round }
      current_reviews.map(&:reviewer_id).should_not include @user1.current_registration.id
      current_reviews.map(&:reviewed_id).should_not include @user1.current_registration.id
    end

    it "he can not change participation to reviews" do
      visit mypage_path
      fill_in "student_number", :with => @user1.student_number
      click_button "start!"

      # perhaps not the best way to check that a button does not exist at page
      expect{
        click_button "cancel participation"
      }.to raise_error
    end
  end

  describe "if user cancels the participation" do
    before do
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user2)
      @user3 = FactoryGirl.create(:user3)
      @registration1 = FactoryGirl.create(:registration, :user => @user1, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration2 = FactoryGirl.create(:registration, :user => @user2, :course => @course, :participate_review1 => true, :participate_review2 => true)
      @registration3 = FactoryGirl.create(:registration, :user => @user3, :course => @course, :participate_review1 => true, :participate_review2 => true)

      visit mypage_path
      fill_in "student_number", :with => @user1.student_number
      click_button "start!"

      click_button "cancel participation"
    end

    it "no assignment is generated for him" do
      visit peer_reviews_path

      click_button "generate default review assignments"

      elements_with_class('.review-assigned').size.should == 2
      elements_with_class('.many-reviews-assigned').size.should == 0
      elements_with_class('.reviewer-assigned').size.should == 2
      elements_with_class('.many-reviewers-assigned').size.should == 0

      student_ids = [@user2.id, @user3.id]
      reviewers = PeerReview.select { |p| p.round==1 }.map { |p| p.reviewer.user.id }
      revieweds = PeerReview.select { |p| p.round==1 }.map { |p| p.reviewed.user.id }

      (reviewers.sort == student_ids.sort).should be true
      (revieweds.sort == student_ids.sort).should be true
    end

    it "he still decide to participate the review" do
      visit mypage_path
      fill_in "student_number", :with => @user1.student_number
      click_button "start!"

      click_button "participate"

      visit peer_reviews_path

      page.should have_content @user1.to_s
    end
  end

  def review_assignments_should_not_collide_for_rounds
    pairs1 = PeerReview.select { |p| p.round==1 }.map { |p| [p.reviewer.id, p.reviewed.id] }
    pairs2 = PeerReview.select { |p| p.round==2 }.map { |p| [p.reviewer.id, p.reviewed.id] }

    (pairs1 & pairs2).should == []
  end

  def button_for user1, user2
    "#b#{user1.id}-#{user2.id}"
  end

  def review_assignment_should_be_good_for_round round
    student_ids = @students.map(&:id)
    reviewers = PeerReview.select { |p| p.round==round }.map { |p| p.reviewer.user.id }
    revieweds = PeerReview.select { |p| p.round==round }.map { |p| p.reviewed.user.id }

    (reviewers.sort == student_ids.sort).should be true
    (revieweds.sort == student_ids.sort).should be true
  end

  def elements_with_class klass
    es = []
    all(klass).each do |e|
      es << e.text
    end
    es
  end

end