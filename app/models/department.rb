class Department < ActiveRecord::Base
  include CodeAndName
  belongs_to :college, primary_key: "code", foreign_key: "college_code"
  has_many :students, class_name: "User", primary_key: "code", foreign_key: "department_code"

  after_save :update_cache

  def update_cache
    Department.update_cache
  end
end
