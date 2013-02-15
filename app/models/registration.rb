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

  def review_targets_for round
    review_targets.select{ |p| p.round == round }
  end

  def review_targets
    PeerReview.select{ |p| p.reviewer_id == id}
  end

  def reviewers_for round
    reviewers.select{ |p| p.round == round }
  end

  def reviewers
    PeerReview.select{ |p| p.reviewed_id == id}
  end

  def feedback_given
    "#{feedback.map(&:week)}"[1..-2]
  end

  def feedback
    week_feedbacks.sort_by{ |f| f[:week] }
  end
end
