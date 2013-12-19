class ChecklistTopicsCheck < ActiveRecord::Base
  attr_accessible :ordering, :weight_factor
  belongs_to :check, class_name: 'ChecklistCheck', :foreign_key => 'checklist_check_id'
  belongs_to :topic, class_name: 'ChecklistTopic', :foreign_key => 'checklist_topic_id'
  default_scope :order => "checklist_topics_checks.ordering"

  def value
    topic.value * weight_factor
  end
  def unchecked_value
    topic.unchecked_value * weight_factor
  end
end
