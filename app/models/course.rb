class Course < ActiveRecord::Base
  attr_accessible :period, :year

  has_many :registrations

  def to_s
    "#{year}, #{period}"
  end
end
