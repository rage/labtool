class AddReviewWillingnesToStudents < ActiveRecord::Migration
  def up
    add_column :registrations, :participate_review1, :boolean
    add_column :registrations, :participate_review2, :boolean
  end

  def down
    remove_column :registrations, :participate_review1
    remove_column :registrations, :participate_review1
  end
end
