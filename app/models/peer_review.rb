class PeerReview < ActiveRecord::Base
  attr_accessible :done, :notes, :round

  belongs_to :reviewer, :class_name => "Registration", :foreign_key => "reviewer_id"
  belongs_to :reviewed, :class_name => "Registration", :foreign_key => "reviewed_id"

  def course
    return reviewer.course unless reviewer.nil?
    reviewed.course unless reviewed.nil?
  end

  def self.delete_for course
    PeerReview.current_for(course).each do |p|
      p.delete
    end
  end

  def self.for course, round
    PeerReview.select do |p|
      p.course == course and p.round == round
    end
  end

  def self.current_for course
    PeerReview.select do |p|
      p.course == course and p.round == course.review_round
    end
  end

  def self.find_matching reviewer, reviewed, round
    PeerReview.all.each do |p|
      return p if p.round==round and p.reviewer==reviewer and p.reviewed == reviewed
    end
    nil
  end

  def self.current_round_for course
    PeerReview.select{ |p| p.course == course and p.round == course.review_round}
  end

  def self.for course, round
    PeerReview.select{ |p| p.course == course and p.round == round}
  end

end
