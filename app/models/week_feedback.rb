class WeekFeedback < ActiveRecord::Base
  attr_accessible :points, :text, :week, :hidden_text, :is_grade
  belongs_to :registration
  belongs_to :giver, class_name: 'User'
  has_many :feedback_comments

  validates :week, :numericality => {:greater_than_or_equal_to => 1}
  validates :points, :numericality => {:greater_than_or_equal_to => 0}
  validate :points_within_range

  def title
    return "Arvostelu ja kurssipalaute" if is_grade
    "viikon #{week} palaute" 
  end

  def max
    # The final grade gets a special treatment
    return 60 if is_grade
    return 3 if registration.course.nil?
    registration.course.week_feedback_max_points || 3
  end

  def user
    registration.user
  end

  def points_within_range
    errors.add(:points, "should be at most #{max}") if points.nil? or points>max
  end

end
