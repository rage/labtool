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
    @students = User.select{ |s| s.registered_to @course }
  end

  def new
    @course = Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end


  def edit
    @course = Course.find(params[:id])
  end


  def create
    @course = Course.new(params[:course])
    @course.review_round = 0
    @course.week = 0

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end
end
