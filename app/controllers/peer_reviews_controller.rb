class PeerReviewsController < ApplicationController
  skip_before_filter :authenticate, :only => :complete_review

  def generate
    students = User.select do |s|
      s.current_registration and
      s.current_registration.participates_review(Course.active.review_round)
    end

    begin
      PeerReview.delete_for Course.active

      registrations = students.map(&:current_registration).shuffle

      up_to = registrations.size.even? ? (registrations.size-1) : (registrations.size/2-1)

      (0..up_to).each do |i|
        create_peer_review registrations[i], registrations[registrations.size-i-1]
      end

      if registrations.size.odd?
        (registrations.size/2..registrations.size-2).each do |i|
          create_peer_review registrations[i], registrations[registrations.size-i-2]
        end
        create_peer_review registrations.last, registrations[registrations.size/2]
      end

    end until unique_assignment

    redirect_to peer_reviews_path, :notice => "default review assignments generated for the current review round"
  end

  def unique_assignment
    return true if Course.active.review_round == 1
    this_round = PeerReview.current_round_for Course.active
    prev_round = PeerReview.for Course.active, 1
    this_round.each do |this|
      prev_round.each do |prev|
        return false if this.reviewer == prev.reviewer and this.reviewed == prev.reviewed
      end
    end

    true
  end

  def create_peer_review reviewer, reviewed
    round = reviewer.course.review_round
    peer_review = PeerReview.new :done => :false, :round => round
    peer_review.reviewer = reviewer
    peer_review.reviewed = reviewed
    peer_review.save
  end

  def reset
    PeerReview.delete_for Course.active
    redirect_to peer_reviews_path, :notice => "peer review assignments for the current review round reset"
  end

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
  end

  def show
    @peer_review = PeerReview.find(params[:id])
  end

  def new
    @peer_review = PeerReview.new
  end

  def edit
    @peer_review = PeerReview.find(params[:id])
  end

  def create
    @peer_review = PeerReview.new(params[:peer_review])

    if @peer_review.save
      redirect_to @peer_review, notice: 'Peer review was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @peer_review = PeerReview.find(params[:id])

    if @peer_review.update_attributes(params[:peer_review])
      redirect_to @peer_review, notice: 'Peer review was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @peer_review = PeerReview.find(params[:id])
    @peer_review.destroy
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
