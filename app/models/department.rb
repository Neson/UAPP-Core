class Department < ActiveRecord::Base
  belongs_to :college, primary_key: "code", foreign_key: "college_code"
  has_many :students, class_name: "User", primary_key: "code", foreign_key: "department_code"
end
