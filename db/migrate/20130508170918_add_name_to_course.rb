class AddNameToCourse < ActiveRecord::Migration
  def up
    add_column :courses, :name, :string
  end

  def down
    remove_column :courses, :name
  end
end
