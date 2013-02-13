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

  def assigned_to_review user
    puts "**************"
    puts includes?( current_registration.review_targets, user.current_registration)
    puts current_registration.review_targets.inspect
    puts user.current_registration.inspect
    puts "**"
    puts "reviewed => #{current_registration.review_targets.map(&:reviewed).map(&:id)}"
    puts "searched #{user.current_registration.id}"
    return "cancel" if includes?( current_registration.review_targets, user.current_registration)
    "review"
  end

  def includes? review_targets, searched
    review_targets.each { |r|
      return true if r.reviewed == searched
    }

    false
  end

  def number_of_assigned_reviews
    current_registration.review_targets.count
  end

  def reviewers_assigned
    current_registration.reviewers.count
  end


  def self.find_or_create params
    user = User.find_by_student_number params['student_number']
    return user if not user.nil?

    params['password'] = params['student_number']
    params['password_confirmation'] = params['student_number']
    User.create params
  end
end
