class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner

  def self.from_facebook(auth)
    user = where({:fbid => auth.uid}).first_or_create! do |user|
      user.email = "#{Devise.friendly_token[0,20]}@dev.null"
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.gender = auth.extra.raw_info.gender
    end
    return user
  end

  protected

  def send_confirmation_notification?
    false
  end
end
