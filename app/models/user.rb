class User < ActiveRecord::Base
  include RailsSettings::Extend
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid
  validates :name, :gender, :presence => true
  validates_inclusion_of :identity, :in => ["bachelor", "master", "doctor", "professor", "staff", "other", "guest", nil]
  validates_inclusion_of :gender, :in => ["male", "female", "other", nil]
  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }
  scope :unconfirmed, -> { where("confirmed_at IS NULL") }

  has_many :notifications
  has_many :friendships, class_name: "UserFriendship"
  has_many :friends, through: :friendships

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  belongs_to :department, primary_key: "code", foreign_key: "department_code"
  belongs_to :admission_department, class_name: "Department", primary_key: "code", foreign_key: "admission_department_code"

  def avatar(size=100)
    'https://graph.facebook.com/' + fbid.to_s + '/picture?width=' + size.to_s + '&height=' + size.to_s
  end

  def admission_department_name
    admission_department && admission_department.name
  end

  def department_name
    department && department.name
  end

  def college_name
    department && department.college && department.college.name
  end

  def admission_college_name
    admission_department && admission_department.college && admission_department.college.name
  end

  def college_code
    department && department.college && department.college.code
  end

  def admission_college_code
    admission_department && admission_department.college && admission_department.college.code
  end

  def send_notification(title, data={})
    # data = {type: nil, content: nil, url: nil, image: nil, sender_application_id: nil, priority: 3, importance: 3, sender: nil, sender_url: nil, icon: nil, event_name: nil, datetime: nil, location: nil}
    data[:title] = title

    data[:priority] = 3 if data[:priority].to_s == '' || !data[:priority].to_i.between?(0, 3)
    data[:importance] = 3 if data[:importance].to_s == '' || !data[:importance].to_i.between?(0, 3)

    self.notifications.new(data).save!
  end

  def write_login_token_to_cookie(cookies)
    t = Time.now.to_i.to_s
    cookies[:login_token_gtime] = { value: t, domain: '.' + Setting.app_domain }
    cookies[:login_token] = { value: Digest::MD5.hexdigest(Setting.site_secret_key + t + self.id.to_s), domain: '.' + Setting.app_domain }
  end

  def self.from_facebook(auth)
    get_info_connection = HTTParty.get("https://graph.facebook.com/me?fields=id,name,friends,link,picture.height(500).width(500),cover,devices&access_token=#{auth.credentials.token}&locale=#{I18n.locale}")
    info = JSON.parse(get_info_connection.parsed_response)

    user = where({:fbid => auth.uid}).first_or_create! do |user|
      user.email = "#{Devise.friendly_token[0,20]}@dev.null"
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
      user.gender = auth.extra.raw_info.gender
      name = JSON.parse(get_info_connection.parsed_response)['name']
      user.name = name if name
    end

    user.fbtoken = auth.credentials.token
    user.fblink = info['link']
    user.fbcover = info['cover'] && info['cover']['source']
    user.avatar = info['picture'] && info['picture']['data'] && info['picture']['data']['url']
    user.save

    ActiveRecord::Base.transaction do
      user.friends.delete_all
      friends = (info['friends'] && info['friends']['data']) || []
      friend_fbids = friends.map { |f| f['id'] }
      friend_with_ids = User.select(:id).where(fbid: friend_fbids)
      friendship_inserts = friend_with_ids.map { |f| "(#{user.id}, #{f[:id]})" }
      if friendship_inserts.length > 0
        sql = "INSERT INTO user_friendships (user_id, friend_id) VALUES #{friendship_inserts.join(', ')}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    return user
  end

  def get_data
    data = self.attributes
    virtual_attributes.each do |attr|
      data[attr] = self.send(attr)
    end
    return data
  end

  def api_get_data(scopes=[])
    scopes = [] if scopes.to_s == ''
    admin = scopes.include?('admin')

    if scopes.include?('school')
      user_data = self.get_data
    else
      user_data = self.attributes
    end

    data = {}

    data_list = basic_data
    data['uid'] = self.id
    data['mobile_verified'] = self.mobile?

    if scopes.include?('school') || admin
      data['sid'] = self.student_id
      data_list.concat school_data
    end

    if self.public_facebook || scopes.include?('facebook') || admin
      data_list.concat facebook_data
    end

    if scopes.include?('profile') || admin
      data_list.concat profile_data
    end

    data.merge! user_data.select_by_keys(data_list)

    if scopes.include?('friends') || admin
      if admin
        data['friends'] = self.friends.map { |f| f.api_get_data(['facebook']) }
      else
        data['friends'] = self.friends.map { |f| f.api_get_data }
      end
    end

    if admin
      data['settings'] = settings.get_all
      data.merge! self.attributes
    end

    return data
  end

  def api_send_sms(message)
    if self.mobile? && self.mobile.to_s != ''  # 可被接收
      nexmo = Nexmo::Client.new(key: Setting.nexmo_key, secret: Setting.nexmo_secret)
      begin
        nexmo.send_message(from: Setting.site_name, to: self.mobile.tr('^0-9', ''), type: "unicode", text: message)
      rescue
        return {:error => {:message => "Send error", :code => 503}, :status => 503}
      end
    else
      return {:error => {:message => "User has no mobile number", :code => 404}, :status => 404}
    end

    return {:success => {:message => "Ok", :code => 200}, :status => 200}
  end

  def public_facebook
    true
  end

  private

  def virtual_attributes
    [
      "admission_department_name",
      "department_name",
      "college_name",
      "admission_college_name",
      "college_code",
      "admission_college_code",
    ]
  end

  def basic_data
    [
      'id',
      'email',
      'name',
      'gender',
    ]
  end

  def school_data
    [
      'student_id',
      'identity',
      'admission_year',
      'admission_department_code',
      'admission_department_name',
      'admission_college_code',
      'admission_college_name',
      'department_code',
      'department_name',
      'college_code',
      'college_name',
    ]
  end

  def facebook_data
    [
      'fbid',
      'fbcover',
      'avatar',
    ]
  end

  def profile_data
    [
      'brief',
    ]
  end

  def send_confirmation_notification?
    false
  end
end
