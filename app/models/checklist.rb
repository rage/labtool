class Checklist < ActiveRecord::Base
  attr_accessible :title, :ordering, :init_callback, :grade_callback, :remarks
  has_many :questions, class_name: 'ChecklistQuestion', dependent: :destroy, autosave: true
  has_many :answers,    through: :questions, class_name: 'ChecklistAnswer'
  has_many :selected_answers, through: :answers
  has_many :scoretypes, through: :questions, :uniq => true, :order => 'name'
end
