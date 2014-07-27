class AddFieldsToReddit < ActiveRecord::Migration
  def change
    add_column :reddits, :modhash, :string
    add_column :reddits, :cookies, :string
    add_column :reddits, :last_run, :datetime
  end
end
