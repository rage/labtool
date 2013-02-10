class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :year
      t.string :period
      t.boolean :active

      t.timestamps
    end
  end
end
