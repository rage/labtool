class PeerReviewsController < ApplicationController

  def toggle_review

    reviewer = User.find(params[:reviewer]).current_registration
    reviewed = User.find(params[:reviewed]).current_registration
    peer_review = PeerReview.new :done => :false #, :reviewed_id => reviewed.id, :reviewer_id => reviewed.id

    peer_review.reviewer = reviewer
    peer_review.reviewed = reviewed
    peer_review.save

    @selector = "#b#{params[:reviewer]}-#{params[:reviewed]} form input:last"

    respond_to do |format|
      format.js
    end
  end

  def index
    @peer_reviews = PeerReview.all
    @students = User.select{|s| s.current_registration }

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

  # DELETE /peer_reviews/1
  # DELETE /peer_reviews/1.json
  def destroy
    @peer_review = PeerReview.find(params[:id])
    @peer_review.destroy

    respond_to do |format|
      format.html { redirect_to peer_reviews_url }
      format.json { head :no_content }
    end
  end
end
