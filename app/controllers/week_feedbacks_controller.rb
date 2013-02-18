class WeekFeedbacksController < ApplicationController

  def index
    @week_feedbacks = WeekFeedback.all
  end

  def show
    @week_feedback = WeekFeedback.find(params[:id])
  end

  def new
    @week_feedback = WeekFeedback.new
  end

  def edit
    @week_feedback = WeekFeedback.find(params[:id])
  end

  def create
    params[:week_feedback]['text'] = params[:week_feedback]['text'].lstrip.rstrip
    registration = Registration.find(params[:registration])
    earlier_feedback = registration.feedback_for_week (params[:week_feedback][:week]).to_i

    if earlier_feedback
      @week_feedback = earlier_feedback
      @week_feedback.text += "\n-------------------\n"
      @week_feedback.text += params[:week_feedback][:text]
      @week_feedback.points = params[:week_feedback][:points]
      @week_feedback.errors.add(:week, "feedback already exists!")
      @week_feedback.errors.add(:text, "should perhaps be merged with the existing!")
      @registration = registration
      render :action => "edit", :notice => "you already gave feedback for week #{@week_feedback.week}"
    else
      week_feedback = WeekFeedback.new(params[:week_feedback])
      registration.week_feedbacks << week_feedback

      if week_feedback.valid?

        if params[:notify]
          student = week_feedback.user
          reviewer = current_user
          # should be              student.email
          NotificationMailer.email(reviewer.email, reviewer.email, "ks. #{mypage_url+'/'+student.student_number}", " viikon #{week_feedback.week} palaute").deliver
        end

        redirect_to registration.user, :notice => 'Week feedback was successfully created.'
      else
        @week_feedback = week_feedback
        @registration = registration
        render :action => "edit"
      end
    end

  end

  def update
    @week_feedback = WeekFeedback.find(params[:id])

    if @week_feedback.update_attributes(params[:week_feedback])
      redirect_to @week_feedback.registration.user, notice: 'Week feedback was successfully updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @week_feedback = WeekFeedback.find(params[:id])
    @week_feedback.destroy
  end
end
