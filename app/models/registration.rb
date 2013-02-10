class Registration < ActiveRecord::Base
  attr_accessible :repository, :topic

  belongs_to :course
  belongs_to :user
end
