class User < ActiveRecord::Base
  attr_accessible :email, :forename, :student_number, :surename, :password, :password_confirmation

  has_secure_password

  has_many :registrations
  validates :student_number, :numericality => {:only_integer => true}

  def to_s
    "#{forename} #{surename}"
  end

  def current_registration
    registrations.first
    registrations.each { |r|
      return r if r.course == Course.active
    }
    nil
  end

  def registered_to course
    registrations.map(&:course).include? course
  end

  def registration_to course
    registrations.select{ |r| r.course==course  }.first
  end

  def week_feedbacks
    current_registration.week_feedbacks
  end

  def past_registrations
    registrations.select{ |r| r.course.active!=true}
  end

  def assigned_to_review user
    return "cancel" if includes?( current_registration.review_targets_for(Course.active.review_round), user.current_registration)
    "review"
  end

  def reviewed user, course
    review_status = status( registration_to(course).review_targets, user.registration_to(course) )
    return "" if review_status == nil
    return "todo" if review_status==false
    "DONE"
  end

  def reviewed_in_round user, course, round
    review_status = status_in_round( registration_to(course).review_targets, user.registration_to(course), round )
    return "" if review_status == nil
    return "todo" if review_status==false
    "DONE"
  end

  def status review_targets, searched
    review_targets.each { |r|
      return r.done if r.reviewed == searched
    }
    nil
  end

  def status_in_round review_targets, searched, round
    review_targets.each { |r|
      return r.done if r.reviewed == searched and r.round == round
    }
    nil
  end

  def includes? review_targets, searched
    review_targets.each { |r|
      return true if r.reviewed == searched
    }

    false
  end

  def assigned_reviews_in round
    current_registration.review_targets_for round
  end

  def assigned_reviewers_in round
    current_registration.reviewers_for round
  end

  def assigned_reviews
    current_registration.review_targets_for Course.active.review_round
  end

  def assigned_reviewers
    current_registration.reviewers_for Course.active.review_round
  end

  def self.find_or_create params
    user = User.find_by_student_number params['student_number']
    return user if not user.nil?

    params['password'] = params['student_number']
    params['password_confirmation'] = params['student_number']
    User.create params
  end
end
