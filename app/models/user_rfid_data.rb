class UserRfidData < ActiveRecord::Base
  validates :sid, uniqueness: true
  validates :encrypted_code, uniqueness: true

  def user
    User.confirmed.where(student_id: self.sid).first
  end

  def self.find_by_code(code)
    encrypted_code = Digest::MD5.hexdigest(code)
    where(encrypted_code: encrypted_code).first
  end
end
