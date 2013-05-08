class AllowDecimalsInCodeReviewPoints < ActiveRecord::Migration
  def up
    add_column :registrations, :dreview1, :decimal
    add_column :registrations, :dreview2, :decimal
    Registration.all.each do |r|
      r.dreview1 = r.review1
      r.dreview2 = r.review2
      r.save
    end

    remove_column :registrations, :review1
    remove_column :registrations, :review2
    rename_column :registrations, :dreview1, :review1
    rename_column :registrations, :dreview2, :review2
  end

  def down
  end
end
