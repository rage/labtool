class AddCourseAFeldThatDenotesTsMandatoryCodeReviews < ActiveRecord::Migration
  def up
    add_column :courses, :mandatory_reviews, :boolean
  end

  def down
    remove_column :courses, :mandatory_reviews
  end
end
