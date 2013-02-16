class AddWeekToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :week, :integer
  end

  def down
    remove_column :courses, :week
  end
end
