class Course < ActiveRecord::Base
  attr_accessible :period, :year, :review_round, :active, :week, :state

  has_many :registrations

  def review_registration
    return "open" if state == 1
    return "closed"
  end

  def reviews_for_round number
    PeerReview.for self, number
  end

  def to_s
    "#{year}, #{period}"
  end

  def self.active
    Course.where( :active => true ).first
  end
end
