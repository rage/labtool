class CreateWeekFeedbacks < ActiveRecord::Migration
  def change
    create_table :week_feedbacks do |t|
      t.integer :week
      t.integer :points
      t.text :text
      t.references :registration

      t.timestamps
    end
  end
end
