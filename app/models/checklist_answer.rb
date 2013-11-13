class ChecklistAnswer < ActiveRecord::Base
  attr_accessible :answer, :varname, :value, :feedback, :missing_feedback
  belongs_to :question, class_name: 'ChecklistQuestion', foreign_key: 'checklist_question_id'
  default_scope :order => "ordering"
end
