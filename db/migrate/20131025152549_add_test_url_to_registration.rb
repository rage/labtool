class AddTestUrlToRegistration < ActiveRecord::Migration
  def up
    add_column :registrations, :test_url, :string
  end

  def down
    remove_column :registrations, :test_url
  end
end
