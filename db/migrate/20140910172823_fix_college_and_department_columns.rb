class FixCollegeAndDepartmentColumns < ActiveRecord::Migration
  def self.up
    change_column :users, :admission_department_id, :string
    change_column :users, :department_id, :string
    change_column :departments, :college_id, :string

    rename_column :users, :admission_department_id, :admission_department_code
    rename_column :users, :department_id, :department_code
    rename_column :departments, :college_id, :college_code
  end

 def self.down
    rename_column :users, :admission_department_code, :admission_department_id
    rename_column :users, :department_code, :department_id
    rename_column :departments, :college_code, :college_id

    change_column :users, :admission_department_id, :integer
    change_column :users, :department_id, :integer
    change_column :departments, :college_id, :integer
 end
end
