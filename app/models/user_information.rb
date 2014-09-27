class UserInformation < ActiveRecord::Base
  self.inheritance_column = :_type_disabled
  validates_inclusion_of :type, :in => ["other", "work", "club", "skill", "high_school", "hometown", "website", "current_city", "languages", "experience", "favorite_quotes"]
  validates_inclusion_of :privacy, :in => ["public", "friends", "school", "only_me", nil]

  before_validation :set_name

  default_scope { order('sort asc') }

  private

  def set_name
    self.name = type if type != "other"
  end
end
