class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.string :topic
      t.string :repository
      t.references :user
      t.references :course

      t.timestamps
    end
  end
end
