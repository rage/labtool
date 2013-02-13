class PeerReview < ActiveRecord::Base
  attr_accessible :done, :notes

  belongs_to :reviewer, :class_name => "Registration", :foreign_key => "reviewer_id"
  belongs_to :reviewed, :class_name => "Registration", :foreign_key => "reviewed_id"
end
