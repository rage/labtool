class AddActivityToRegistration < ActiveRecord::Migration
  def up
    add_column :registrations, :active, :boolean

    Registration.all.each do |r|
      r.active = true
      r.save!
    end
  end

  def down
    remove_column :registrations, :active
  end
end
