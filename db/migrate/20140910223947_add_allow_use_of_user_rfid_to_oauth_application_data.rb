class AddAllowUseOfUserRfidToOauthApplicationData < ActiveRecord::Migration
  def change
    add_column :oauth_application_data, :allow_use_of_user_rfid, :boolean, :null => false, :default => false
  end
end
