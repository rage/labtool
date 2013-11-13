class Checklist < ActiveRecord::Base
  attr_accessible :title, :ordering, :init_callback, :grade_callback
  has_many :questions, class_name: 'ChecklistQuestion', dependent: :destroy, autosave: true
  has_many :scoretypes, through: :questions, :uniq => true, :order => 'name'
end
