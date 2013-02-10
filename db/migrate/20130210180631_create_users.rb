class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :forename
      t.string :surename
      t.string :student_number
      t.string :email
      t.boolean :admin

      t.timestamps
    end
  end
end
