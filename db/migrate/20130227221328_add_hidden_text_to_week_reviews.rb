class AddHiddenTextToWeekReviews < ActiveRecord::Migration
  def up
    add_column :week_feedbacks, :hidden_text, :text
  end

  def down
    remove_column :week_feedbacks, :hidden_text
  end
end
