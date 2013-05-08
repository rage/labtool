class MakePointsDecimal < ActiveRecord::Migration
  def up
    add_column :week_feedbacks, :dpoints, :decimal
    WeekFeedback.all.each do |w|
      w.dpoints = w.points
      w.save
    end

    remove_column :week_feedbacks, :points
    rename_column :week_feedbacks, :dpoints, :points

  end

  def down
  end
end
