class AddGradeAndGradePointsToRegistration < ActiveRecord::Migration
  def change
    add_column :week_feedbacks, :is_grade, :boolean, :null => false, :default => false
    add_column :registrations, :grade, :integer
  end
end
