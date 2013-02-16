class PeerReviewsController < ApplicationController
  skip_before_filter :authenticate, :only => :complete_review

  def complete_review
    review = PeerReview.find(params[:review])
    review.update_attributes :done => true

    redirect_to "/mypage/#{review.reviewer.user.student_number}"
  end


  def toggle_review
    reviewer = User.find(params[:reviewer]).current_registration
    reviewed = User.find(params[:reviewed]).current_registration
    round = reviewer.course.review_round

    review = PeerReview.find_matching reviewer, reviewed, round

    if review.nil?
      peer_review = PeerReview.new :done => :false, :round => round
      peer_review.reviewer = reviewer
      peer_review.reviewed = reviewed
      peer_review.save
      @label = "cancel"
    else
      review.delete
      @label = "review"
    end

    @reviewer_class = reviewer_class reviewer
    @reviewed_class = reviewed_class reviewed

    @selector = "#b#{params[:reviewer]}-#{params[:reviewed]} form input:last"
    @class_selector = "#b#{params[:reviewer]}-#{params[:reviewed]}"
    @student_selector = "#s#{params[:reviewer]}"
    @review_target_selector = "#r#{params[:reviewed]}"
    @reviews_count_selector = "#reviews#{params[:reviewer]}"
    @reviewers_count_selector = "#reviewers#{params[:reviewed]}"
    @reviewers_count = reviewed.user.assigned_reviewers.count
    @reviews_count = reviewer.user.assigned_reviews.count

    puts "******************"
    puts "reviewers #{@reviewers_count}"
    puts "reviews #{@reviews_count}"

    respond_to do |format|
      format.js
    end
  end

  def index
    @peer_reviews = PeerReview.current_round_for Course.active
    @students = User.select do |s|
      s.current_registration and
      s.current_registration.participates_review(Course.active.review_round)
    end
    @course = Course.active

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @peer_reviews }
    end
  end

  def show
    @peer_review = PeerReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @peer_review }
    end
  end

  def new
    @peer_review = PeerReview.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @peer_review }
    end
  end

  def edit
    @peer_review = PeerReview.find(params[:id])
  end

  def create
    @peer_review = PeerReview.new(params[:peer_review])

    respond_to do |format|
      if @peer_review.save
        format.html { redirect_to @peer_review, notice: 'Peer review was successfully created.' }
        format.json { render json: @peer_review, status: :created, location: @peer_review }
      else
        format.html { render action: "new" }
        format.json { render json: @peer_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @peer_review = PeerReview.find(params[:id])

    respond_to do |format|
      if @peer_review.update_attributes(params[:peer_review])
        format.html { redirect_to @peer_review, notice: 'Peer review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @peer_review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @peer_review = PeerReview.find(params[:id])
    @peer_review.destroy

    respond_to do |format|
      format.html { redirect_to peer_reviews_url }
      format.json { head :no_content }
    end
  end

  private

  def reviewer_class reviewer
    if reviewer.user.assigned_reviews.count > 1
      return "many-reviews-assigned"
    elsif reviewer.user.assigned_reviews.count == 1
      return "review-assigned"
    end
    ""
  end

  def reviewed_class reviewed
    if reviewed.user.assigned_reviewers.count > 1
      return "many-reviewers-assigned"
    elsif reviewed.user.assigned_reviewers.count == 1
      return "review-assigned"
    end
    ""
  end

end
