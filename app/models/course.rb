class Course < ActiveRecord::Base
  attr_accessible :period, :year, :review_round

  has_many :registrations

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
