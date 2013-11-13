class SelectedAnswer < ActiveRecord::Base
  attr_accessible :selected
  belongs_to :answer, class_name: 'ChecklistAnswer', foreign_key: 'checklist_answer_id'
  belongs_to :registration
end
