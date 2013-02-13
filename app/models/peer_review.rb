class PeerReview < ActiveRecord::Base
  attr_accessible :done, :notes, :round

  belongs_to :reviewer, :class_name => "Registration", :foreign_key => "reviewer_id"
  belongs_to :reviewed, :class_name => "Registration", :foreign_key => "reviewed_id"

  def self.find_matching reviewer, reviewed, round
    PeerReview.all.each do |p|
      return p if p.round==round and p.reviewer==reviewer and p.reviewed == reviewed
    end
    nil
  end
end
