class Course < ActiveRecord::Base
  attr_accessible :period, :year, :review_round, :active, :week, :state, :mandatory_reviews, :name, :week_feedback_max_points, :email_instructor, :email_student, :weeks_total, :reviews_total, :default_checklist_id

  #has_one :default_checklist, class_name: "Checklist"
  has_many :registrations, :dependent => :destroy
  has_many :users, through: :registrations

  has_many :active_registrations, class_name: 'Registration', conditions: {active: true}
  has_many :active_users, through: :active_registrations, source: :user

  scope :past, -> {where(active: false)}

  validates :week, :presence => true
  validates :weeks_total, :presence => true
  validates :period, :presence => true
  validates :year,  numericality: {only_integer: true, greater_than_or_equal_to: 1970, less_than_or_equal_to: 2100}

  def review_registration
    return "open" if state == 1
    return "closed"
  end

  def registered_users
    #User.select { |s| s.registered_to self }.sort_by{ |s| s.surename.downcase }
    registrations.map{ |r| r.user }.uniq
  end

  def review_participants
    active_users.order(:surename).select{|s| s.review_eligibility_for_course_round?(self)}
  end

  def reviewers
    active_users.order(:surename).select{|s| s.review_eligibility_for_course_round?(self)}.reject{|s| s.reviewer_for_course_round?(self)}
  end

  def review_targets
    active_users.order(:surename).select{|s| s.review_eligibility_for_course_round?(self)}.reject{|s| s.review_target_for_course_round?(self)}
  end

  def reviews_for_round number
    PeerReview.for self, number
  end

  def to_s
    "#{name} #{period}/#{year%100}"
  end

  def self.active
    Course.where( :active => true )
  end

end
