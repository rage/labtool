class AddDemoParticipationToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :showed_up_in_demo, :boolean
  end
end
