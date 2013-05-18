class AddOptionsToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :week_feedback_max_points, :integer
    add_column :courses, :email_student, :boolean
    add_column :courses, :email_instructor, :boolean

    Course.all.each do |c|
      c.week_feedback_max_points = 3
      c.email_student = true
      c.email_instructor = false
      c.save
    end
  end

  def down
    remove_column :courses, :week_feedback_max_points
    remove_column :courses, :email_student
    remove_column :courses, :email_instructor
  end
end
