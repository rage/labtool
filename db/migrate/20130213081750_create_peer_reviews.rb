class CreatePeerReviews < ActiveRecord::Migration
  def change
    create_table :peer_reviews do |t|
      t.string :notes
      t.boolean :done

      t.timestamps
    end
  end
end
