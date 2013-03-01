class AddReviewPointsToRegistration < ActiveRecord::Migration
  def up
    add_column :registrations, :review1, :integer
    add_column :registrations, :review2, :integer
  end

  def down
    remove_column :registrations, :review1
    remove_column :registrations, :review2
  end
end
