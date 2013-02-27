class WeekFeedbacksController < ApplicationController

  def index
    @week_feedbacks = WeekFeedback.all
  end

  def create
    params[:week_feedback]['text'] = params[:week_feedback]['text'].lstrip.rstrip
    @registration = Registration.find(params[:registration])
    earlier_feedback = @registration.feedback_for_week (params[:week_feedback][:week]).to_i

    if earlier_feedback
      @week_feedback = prepare_based_on earlier_feedback, params
      return render :action => "edit", :notice => "you already gave feedback for week #{@week_feedback.week}"
    end

    week_feedback = WeekFeedback.new(params[:week_feedback])
    @registration.week_feedbacks << week_feedback

    if week_feedback.valid?

      if params[:notify]
        student = week_feedback.user
        reviewer = current_user
        # should be              student.email
        NotificationMailer.email(reviewer.email, reviewer.email, "ks. #{mypage_url+'/'+student.student_number}", "viikon #{week_feedback.week} palaute").deliver
      end

      redirect_to @registration.user, :notice => 'Week feedback was successfully created.'
    else
      @week_feedback = week_feedback
      render :action => "edit"
    end


  end

  def update
    @week_feedback = WeekFeedback.find(params[:id])

    if @week_feedback.update_attributes(params[:week_feedback])
      redirect_to @week_feedback.registration.user, :notice => 'Week feedback was successfully updated'
    else
      @registration = Registration.find(params[:registration])
      render :action => "edit"
    end
  end

  def destroy
    @week_feedback = WeekFeedback.find(params[:id])
    @week_feedback.destroy
    redirect_to week_feedbacks_path
  end

  private

  def prepare_based_on earlier_feedback, params
    week_feedback = earlier_feedback
    week_feedback.text += "\n-------------------\n" unless params[:week_feedback][:text].empty?
    week_feedback.text += params[:week_feedback][:text] unless params[:week_feedback][:text].empty?
    week_feedback.hidden_text = "" if week_feedback.hidden_text.nil?
    week_feedback.hidden_text += "\n-------------------\n" unless week_feedback.hidden_text.empty? or params[:week_feedback][:hidden_text].empty?
    week_feedback.hidden_text += params[:week_feedback][:hidden_text] unless params[:week_feedback][:hidden_text].empty?
    week_feedback.points = params[:week_feedback][:points] unless params[:week_feedback][:points].empty?
    week_feedback.errors.add(:week, "feedback already exists!")
    week_feedback.errors.add(:text, "should perhaps be merged with the existing!")
    week_feedback.errors.add(:hidden_text, "should perhaps be merged with the existing!")
    week_feedback
  end
end
