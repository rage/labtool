class FeedbackCommentsController < ApplicationController
  skip_before_filter :authenticate, only: [:create]

  def create
    params[:feedback_comment]['text'] = params[:feedback_comment]['text'].lstrip.rstrip
    @feedback = WeekFeedback.find(params[:week_feedback])
    @user = User.find_by_student_number(session[:student_number])

    unless @feedback.registration.user == @user
      redirect_to "/mypage", notice: "You have no right to be here!"
      return
    end

    comment = FeedbackComment.new(params[:feedback_comment])
    comment.user = @user

    @feedback.feedback_comments << comment

    student = @user
    reviewer = @feedback.giver
    begin
      NotificationMailer.email(reviewer.email, reviewer.email, "Palautettasi on kommentoitu\nks. #{user_url student}", "viikon #{@feedback.week} palaute", params['notify-cc'], @feedback.registration.course).deliver
    rescue
      redirect_to "/mypage/#{@user.student_number}", :notice => "Sending email to instructor failed. But comment was successfully saved to labtool."
      return
    end
    redirect_to "/mypage/#{@user.student_number}", :notice => "Comment was successfully created."
  end

  def create_admin_reply
    params[:feedback_comment]['text'] = params[:feedback_comment]['text'].lstrip.rstrip
    @feedback = WeekFeedback.find(params[:week_feedback])

    comment = FeedbackComment.new(params[:feedback_comment])
    comment.user = current_user

    @feedback.feedback_comments << comment

    if params[:notify]
      student = @feedback.user
      reviewer = current_user
      NotificationMailer.email(reviewer.email, student.email, "Palautettasi on kommentoitu\nks. #{mypage_url+'/'+student.student_number}", "viikon #{@feedback.week} palaute", params['notify-cc'], @feedback.registration.course).deliver
    end

    redirect_to @feedback.registration.user, :notice => 'Comment was successfully created.'

  end

end
