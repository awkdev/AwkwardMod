class ChangeAttribTypesInPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :post_id, :integer
    remove_column :posts, :comment_id, :integer
    add_column :posts, :post_id, :string
    add_column :posts, :comment_id, :string
  end
end
