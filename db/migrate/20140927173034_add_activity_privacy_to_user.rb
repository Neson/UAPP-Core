class AddActivityPrivacyToUser < ActiveRecord::Migration
  def change
    add_column :users, :activity_privacy, :string, null: false, default: 'public'
  end
end
