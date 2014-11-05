class MypageController < ApplicationController
  skip_before_filter :authenticate

  def redirect

    number = params[:student_number].lstrip.rstrip
    email = params[:email].lstrip.rstrip

    user = User.where(:student_number => number).first unless User.where(:student_number => number).empty?

    if User.where(:student_number => number).empty? or user.email != email or user.hidden?
      redirect_to "/mypage", :notice => "enter your student number and email address"
    else
      session[:student_number] = number
      redirect_to "/mypage/#{number}"

    end

    #number = params[:student_number].lstrip.rstrip
    #if ( User.where(:student_number => number).empty?)
    #  redirect_to "/mypage",
    #              :notice => "'#{number}' is not a know student number. Have you already "
    #else
    #  session[:student_number] = number
    #  redirect_to "/mypage/#{number}"
    #end
  end

  def show
    if admin? and params[:student_number]
      @user = User.find_by_student_number(params[:student_number])
    elsif session[:student_number]
      @user = User.find_by_student_number(session[:student_number])
    else
      redirect_to "/mypage", :notice => "enter your student number and email address"
    end
  end

  def edit
    number = session[:student_number]
    number = params[:student_number] if admin?
    @user = User.find_by_student_number(number)
  end

  def update
    if admin? and params[:student_number]
      @user = User.find_by_student_number(params[:student_number])
    elsif session[:student_number]
      @user = User.find_by_student_number(session[:student_number])
    end
    @user.update_attributes(params[:user].except(:registration))
    params[:user][:registration].each do |id, value|
      @user.registrations.find(id).update_attributes(value)
    end
    redirect_to "/mypage/#{@user.student_number}", :notice => "your data has been updated"
  end
end
