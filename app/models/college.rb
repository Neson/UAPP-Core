class College < ActiveRecord::Base
  include CodeAndName
  has_many :departments, primary_key: "code", foreign_key: "college_code"

  after_save :update_cache

  def update_cache
    College.update_cache
  end
end
