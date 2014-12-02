class CoursesController < ApplicationController

  def index
    @courses = Course.order('active DESC, year DESC, period DESC')
  end

  def active
    course = Course.find(params[:id])
    course.update_attributes :active => true unless course.nil?
    redirect_to courses_path
  end

  def inactive
    course = Course.find(params[:id])
    course.update_attributes :active => false unless course.nil?

    redirect_to courses_path
  end

  def show
    @course = Course.includes(:registrations => [:week_feedbacks]).where( :id => params[:id]).first
    @registrations = Registration.includes(:week_feedbacks, :user).where( :course_id => @course.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registrations, :methods => [:user] }
      format.json  { render :json => @registrations, :methods => [:user] }
    end
  end

  def new
    @course = Course.new
  end

  def edit
    @course = Course.find(params[:id])
  end

  def create
    @course = Course.new(params[:course])
    @course.review_round = 0
    @course.week = 0
    @course.active = false

    if @course.save
      redirect_to @course, :notice => 'Course was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    do_update :course, params
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to courses_path, :notice => 'Course was destroyed'
  end

end
