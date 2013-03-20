class CoursesController < ApplicationController

  def index
    @courses = Course.all
  end

  def activity
    Course.all.each do |c|
      c.update_attributes :active => c.id == params[:id].to_i
    end
    redirect_to courses_path
  end

  def show
    @course = Course.find(params[:id])
    @students = User.select { |s| s.registered_to @course }.sort_by{ |s| s.surename.downcase }
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
