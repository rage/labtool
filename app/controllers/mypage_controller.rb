class MypageController < ApplicationController
  skip_before_filter :authenticate

  def foobar
    @student = User.find_by_student_number(params[:student_number])
    @test = "testi"

    respond_to do |format|
      format.js
    end
  end

  def redirect
    number = params[:student_number]
    if ( User.where(:student_number => number).empty?)
      redirect_to "/mypage", :notice => "'#{number}' is not a know student number"
    else
      session[:student_number] = number
      redirect_to "/mypage/#{number}"
    end
  end

  def show
    if session[:student_number]
      @user = User.find_by_student_number(session[:student_number])
    else
      redirect_to "/mypage", :notice => "enter your student number"
    end
  end

  def edit
    @user = User.find_by_student_number(session[:student_number])
  end

  def update
    @user = User.find_by_student_number(session[:student_number])

    @user.update_attributes(params[:user].except(:registration))
    @user.current_registration.update_attributes(params[:user][:registration]) unless params[:user][:registration].nil?
    redirect_to "/mypage/#{@user.student_number}", :notice => "your data updated"
  end
end