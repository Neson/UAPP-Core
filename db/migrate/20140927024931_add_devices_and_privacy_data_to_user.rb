class AddDevicesAndPrivacyDataToUser < ActiveRecord::Migration
  def change
    add_column :users, :devices, :string
    add_column :users, :school_data_privacy, :string, null: false, default: 'public'
    add_column :users, :information_privacy, :string, null: false, default: 'public'
  end
end
