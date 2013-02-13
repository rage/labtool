class SupportForMultiplePeerReviews < ActiveRecord::Migration
  def up
    add_column :peer_reviews, :round, :integer
    add_column :courses, :review_round, :integer
  end

  def down
    remove_column :peer_reviews, :round
    remove_column :courses, :review_round
  end
end
