class CreateReddits < ActiveRecord::Migration
  def change
    create_table :reddits do |t|

      t.timestamps
    end
  end
end
