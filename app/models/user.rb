class User < ActiveRecord::Base
  attr_accessible :email, :forename, :student_number, :surename, :password, :password_confirmation

  has_secure_password

  has_many :registrations

  def to_s
    "#{forename} #{surename}"
  end

  # FIXTHIS!
  def current_registration
    registrations.first
  end

  def week_feedbacks
    current_registration.week_feedbacks
  end

  def past_registrations
    registrations.select{ |r| r.course.active!=true}
  end

  def self.find_or_create params
    user = User.find_by_student_number params['student_number']
    return user if not user.nil?

    params['password'] = params['student_number']
    params['password_confirmation'] = params['student_number']
    User.create params
  end
end
