class WeekFeedback < ActiveRecord::Base
  attr_accessible :points, :text, :week
  belongs_to :registration

  def user
    registration.user
  end
end
