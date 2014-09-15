class College < ActiveRecord::Base
  has_many :departments, primary_key: "code", foreign_key: "college_code"
end
