class PeerReviewsController < ApplicationController
  skip_before_filter :authenticate, :only => :complete_review

  def generate
    begin
      generate_peer_review_assignment
    end until unique_assignment

    redirect_to peer_reviews_path, :notice => "default review assignments generated for the current review round"
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
      create_peer_review reviewer, reviewed
      @label = "cancel"
    else
      review.delete
      @label = "review"
    end

    prepare_for_js reviewer, reviewed

    respond_to do |format|
      format.js
    end
  end

  def prepare_for_js(reviewer, reviewed)
    reviewer_id = reviewer.user.id
    reviewed_id = reviewed.user.id

    @reviewer_class = class_for reviewer, 'review'

    @reviewed_class = class_for reviewed, 'reviewer'

    @selector = "#b#{reviewer_id}-#{reviewed_id} form input:last"
    @class_selector = "#b#{reviewer_id}-#{reviewed_id}"
    @student_selector = "#s#{reviewer_id}"
    @review_target_selector = "#r#{reviewed_id}"
    @reviews_count_selector = "#reviews#{reviewer_id}"
    @reviewers_count_selector = "#reviewers#{reviewed_id}"
    @reviewers_count = reviewed.user.assigned_reviewers.count
    @reviews_count = reviewer.user.assigned_reviews.count
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
    do_update :peer_review, params
  end

  def destroy
    @peer_review = PeerReview.find(params[:id])
    @peer_review.destroy
  end

  private

  def generate_peer_review_assignment
    PeerReview.delete_for Course.active

    registrations = User.review_participants.map(&:current_registration).shuffle

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

  def create_peer_review(reviewer, reviewed)
    round = reviewer.course.review_round
    peer_review = PeerReview.new :done => :false, :round => round
    peer_review.reviewer = reviewer
    peer_review.reviewed = reviewed
    peer_review.save
  end

  def class_for object, klass
    method = "assigned_#{klass}s".to_sym
    count = object.user.send(method).count
    if count > 1
      return "many-#{klass}s-assigned"
    elsif count == 1
      return "#{klass}-assigned"
    end
    ""
  end

end
