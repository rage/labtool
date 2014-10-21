class CoursesController < ApplicationController
  #caches_action :show

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

    Course.all.each do |c|
      c.update_attributes :active => c.id == params[:id].to_i
    end
    redirect_to courses_path
  end

  def show
    @course = Course.includes(:registrations => [:week_feedbacks]).where( :id => params[:id]).first
    @registrations = Registration.includes(:week_feedbacks, :user).where( :course_id => @course.id)

    @current = @course == Course.active

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
    expire_fragment('current_course')
    #expire_action :controller => 'courses', :action => 'show', :id => Course.active.id
    @course = Course.find(params[:id])
  end

  def create
    expire_fragment('current_course')
    #expire_action :controller => 'courses', :action => 'show', :id => Course.active.id
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
    expire_fragment('current_course')
    #expire_action :controller => 'courses', :action => 'show', :id => Course.active.id
    do_update :course, params
  end

  def destroy
    expire_fragment('current_course')
    #expire_action :controller => 'courses', :action => 'show', :id => Course.active.id
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to courses_path, :notice => 'Course was destroyed'
  end

end
