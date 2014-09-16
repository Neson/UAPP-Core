class AddIndexToKey < ActiveRecord::Migration
  def change
    add_index :notifications, :user_id
    add_index :oauth_application_data, :application_id
    add_index :user_friendships, :user_id
    add_index :user_friendships, :friend_id
    add_index :colleges, :code
    add_index :departments, :code
  end
end
