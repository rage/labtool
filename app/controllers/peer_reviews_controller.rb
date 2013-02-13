class PeerReviewsController < ApplicationController
  # GET /peer_reviews
  # GET /peer_reviews.json
  def index
    @peer_reviews = PeerReview.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @peer_reviews }
    end
  end

  # GET /peer_reviews/1
  # GET /peer_reviews/1.json
  def show
    @peer_review = PeerReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @peer_review }
    end
  end

  # GET /peer_reviews/new
  # GET /peer_reviews/new.json
  def new
    @peer_review = PeerReview.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @peer_review }
    end
  end

  # GET /peer_reviews/1/edit
  def edit
    @peer_review = PeerReview.find(params[:id])
  end

  # POST /peer_reviews
  # POST /peer_reviews.json
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

  # PUT /peer_reviews/1
  # PUT /peer_reviews/1.json
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
