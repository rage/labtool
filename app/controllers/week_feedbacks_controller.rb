class WeekFeedbacksController < ApplicationController

  def index
    @week_feedbacks = WeekFeedback.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @week_feedbacks }
    end
  end

  def show
    @week_feedback = WeekFeedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @week_feedback }
    end
  end

  def new
    @week_feedback = WeekFeedback.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @week_feedback }
    end
  end

  def edit
    @week_feedback = WeekFeedback.find(params[:id])
  end

  def create
    params[:week_feedback]['text'] = params[:week_feedback]['text'].lstrip.rstrip
    week_feedback = WeekFeedback.new(params[:week_feedback])
    registration = Registration.find(params[:registration])
    registration.week_feedbacks << week_feedback

    if week_feedback.valid?
      redirect_to registration.user, notice: 'Week feedback was successfully created.'
    else
      @week_feedback = week_feedback
      @registration = registration
      render :action => "edit"
    end
  end

  def update
    @week_feedback = WeekFeedback.find(params[:id])

    respond_to do |format|
      if @week_feedback.update_attributes(params[:week_feedback])
        format.html { redirect_to @week_feedback, notice: 'Week feedback was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @week_feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /week_feedbacks/1
  # DELETE /week_feedbacks/1.json
  def destroy
    @week_feedback = WeekFeedback.find(params[:id])
    @week_feedback.destroy

    respond_to do |format|
      format.html { redirect_to week_feedbacks_url }
      format.json { head :no_content }
    end
  end
end
