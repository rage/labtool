class WeekFeedback < ActiveRecord::Base
  attr_accessible :points, :text, :week
  belongs_to :registration

  validates :week, :numericality => true
  validates :points, :numericality => true

  def user
    registration.user
  end
end
