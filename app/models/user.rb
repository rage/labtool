class User < ActiveRecord::Base
  attr_accessible :email, :forename, :student_number, :surename, :password, :password_confirmation

  has_many :registrations
  has_secure_password

  def to_s
    "#{forename} #{surename}"
  end

  # FIXTHIS!
  def current_registration
    registrations.first
  end

  def self.find_or_create params
    user = User.find_by_student_number params['student_number']
    return user if not user.nil?

    params['password'] = params['student_number']
    params['password_confirmation'] = params['student_number']
    User.create params
  end
end
