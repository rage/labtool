class Registration < ActiveRecord::Base
  attr_accessible :repository, :topic

  belongs_to :course
  belongs_to :user
  has_many :week_feedbacks

  def self.current
    Registration.all.select{|r| r.course.active }
  end

  def self.past
    Registration.all.reject{|r| r.course.active }
  end

  def feedback_given
    "#{feedback.map(&:week)}"[1..-2]
  end

  def feedback
    week_feedbacks.sort_by{ |f| f[:week] }
  end
end
