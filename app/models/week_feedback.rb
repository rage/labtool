class WeekFeedback < ActiveRecord::Base
  attr_accessible :points, :text, :week
  belongs_to :registration

  validates :week, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 6}
  validates :points, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 3}

  def user
    registration.user
  end
end
