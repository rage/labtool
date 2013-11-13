class ChecklistAnswer < ActiveRecord::Base
  attr_accessible :answer, :varname, :value, :feedback, :missing_feedback
  belongs_to :question, class_name: 'ChecklistQuestion', foreign_key: 'checklist_question_id'
  has_many :selected_answers
  default_scope :order => "checklist_answers.ordering"

  def checked?(registration = nil) 
    return false if registration.nil?

    selected = selected_answers.find_by_registration_id registration
    
    return false if selected.nil?
    selected.selected
  end
end
