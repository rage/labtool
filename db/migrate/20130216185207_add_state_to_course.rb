class AddStateToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :state, :integer
  end

  def down
    remove_column :courses, :state
  end
end
