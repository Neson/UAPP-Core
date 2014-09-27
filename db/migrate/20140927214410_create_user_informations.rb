class CreateUserInformations < ActiveRecord::Migration
  def change
    create_table :user_informations do |t|
      t.integer :user_id, null: false
      t.string :type, null: false, default: 'other'
      t.string :name, null: false
      t.string :value, null: false
      t.integer :sort, null: false, default: 0
      t.string :privacy, null: false, default: 'public'

      t.timestamps
    end
  end
end
