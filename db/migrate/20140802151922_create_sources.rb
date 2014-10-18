class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :domain
      t.string :heading
      t.string :subheading

      t.timestamps
    end
  end
end
