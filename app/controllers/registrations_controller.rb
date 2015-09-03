class RegistrationsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create, :redirect]

  def toggle_activity
    @registration = Registration.find(params[:registration])
    @registration.toggle_activity
    @registration.save
    redirect_to :back, :notice=> 'Registration status changed'
  end

  def toggle_demo_participation
    expire_fragment('current_course')
    @registration = Registration.find(params[:registration])
    @registration.toggle_demo_participation
    @registration.save

    respond_to do |format|
      format.js
      format.html {
        redirect_to :back, :notice=> 'Registration status changed'
      }
    end
  end

  def index
    @courses = Course.active
    @past_courses = Course.past

    @past_registrations = Registration.past
  end

  def show
    @registration = Registration.find(params[:id])
  end

  def new
    @registration = Registration.new
    if params[:id]
      course = Course.find(params[:id])
      @registration.course = course if course.active
    end
  end

  def edit
    @registration = Registration.find(params[:id])
    render "admin_edit"
  end

  def create
    course = Course.find_by_id(params[:registration][:course_id])
    user = User.find_or_create(params[:user])

    if user.has_registered?(course)
      return redirect_to "/mypage/#{user.student_number}",
                         :notice => "You have already registered for the current course!"
    end

    @registration = Registration.new(params[:registration])
    if user.valid? and @registration.valid? and not course.nil? and course.active
      @registration.participate_review1 = true
      @registration.participate_review2 = true
      @registration.active = true
      user.registrations << @registration
      course.registrations << @registration
      session[:student_number] = user.student_number
      redirect_to "/mypage/#{user.student_number}", :notice =>'Registration done!'
    else
      @user = user
      render :action => "edit"
    end
  end

  def update
    @registration = Registration.find(params[:id])
    @registration.update_attributes(params[:registration])
    redirect_to @registration.user, :notice => "Registration was successfully updated"
  end

  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy
    redirect_to registrations_path, :notice => 'Registration destroyed'
  end
end
