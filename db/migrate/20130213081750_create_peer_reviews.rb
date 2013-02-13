class CreatePeerReviews < ActiveRecord::Migration
  def change
    create_table :peer_reviews do |t|
      t.string :notes
      t.boolean :done
      t.integer :reviewer_id
      t.integer :reviewed_id

      t.timestamps
    end
  end
end
