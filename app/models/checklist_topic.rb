class ChecklistTopic < ActiveRecord::Base
  attr_accessible :title, :varname, :ordering, :update_callback, :init_callback
  has_many :checks, class_name: 'ChecklistCheck', dependent: :destroy, autosave: true
  belongs_to :scoretype
  belongs_to :checklist
end
