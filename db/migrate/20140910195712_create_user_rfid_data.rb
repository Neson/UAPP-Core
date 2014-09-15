class CreateUserRfidData < ActiveRecord::Migration
  def change
    create_table :user_rfid_data do |t|
      t.string :sid, :null => false
      t.string :encrypted_code, :null => false

      t.timestamps
    end

    add_index :user_rfid_data, :sid, unique: true
    add_index :user_rfid_data, :encrypted_code, unique: true
  end
end
