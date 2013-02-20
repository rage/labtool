class RegistrationsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create, :redirect, :toggle_participation]
#  skip_before_filter :authenticate, :only => [:new, :edit, :create, :update, :redirect, :toggle_participation]


  def index
    @registrations = Registration.current
    @past_registrations = Registration.past
  end

  def show
    @registration = Registration.find(params[:id])
  end

  def new
    @registration = Registration.new
  end

  def edit
    @registration = Registration.find(params[:id])
    render "admin_edit"
  end

  def toggle_participation
    @registration = Registration.find(params[:registration])
    @registration.toggle_review_participation params[:round].to_i
    @registration.save
    redirect_to "/mypage/#{@registration.user.student_number}", :notice => 'Code review participation status changed'
  end

  def create
    course = Course.find_by_active(true)
    user = User.find_or_create(params[:user])

    @registration = Registration.new(params[:registration])
    if user.valid?
      @registration.participate_review1 = true
      @registration.participate_review2 = true
      user.registrations << @registration
      course.registrations << @registration
      session[:student_number] = user.student_number
      redirect_to "/mypage/#{user.student_number}", notice: 'Registration done!'
    else
      @user = user
      render :action => "edit"
    end
  end

  def update
    do_update :registration, params
  end

  def destroy
    @registration = Registration.find(params[:id])
    @registration.destroy
    redirect_to registrations_path, :notice => 'Registration destroyed'
  end
end
