class User < ActiveRecord::Base
  include RailsSettings::Extend
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  validates_uniqueness_of :fbid
  validates :name, :gender, :presence => true
  validates_inclusion_of :identity, :in => ["bachelor", "master", "doctor", "professor", "staff", "other", "guest"]
  validates_inclusion_of :gender, :in => ["male", "female", "other"]
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

  def admission_college_name
    admission_department && admission_department.college && admission_department.college.name
  end

  def admission_department_name
    admission_department && admission_department.name
  end

  def college_name
    department && department.college && department.college.name
  end

  def department_name
    department && department.name
  end

  def send_notification(title, type=nil, content=nil, url=nil, image=nil, sender_application_id=nil, priority=3, importance=3, sender=nil, sender_url=nil, icon=nil, event_name=nil, datetime=nil, location=nil)

    priority = 3 if priority.to_s == ''
    importance = 3 if importance.to_s == ''
    priority = priority.to_i
    importance = importance.to_i
    priority = 3 if !priority.between?(0, 3)
    importance = 3 if !importance.between?(0, 3)

    self.notifications.new({title: title, type: type, content: content, url: url, image: image, sender_application_id: sender_application_id, priority: priority, importance: importance, sender: sender, sender_url: sender_url, icon: icon, event_name: event_name, datetime: datetime, location: location}).save!
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

  def api_get_data(scopes=[], admin=false)
    userdata = {}
    userdata['id'] = self.id
    userdata['uid'] = self.id
    userdata['email'] = self.email
    userdata['name'] = self.name
    userdata['gender'] = self.gender
    if self.mobile?
      userdata['mobile_verified'] = true
    else
      userdata['mobile_verified'] = false
    end
    if scopes.include?('school') || admin
      userdata['sid'] = self.student_id
      userdata['student_id'] = self.student_id
      userdata['identity'] = self.identity
      userdata['admission_year'] = self.admission_year
      userdata['admission_department_code'] = self.admission_department_code
      userdata['department_code'] = self.department_code
      userdata['college'] = self.department && self.department.college && self.department.college.name
      userdata['admission_department'] = self.admission_department && self.admission_department.name
      userdata['department'] = self.department && self.department.name
    end
    if scopes.include?('facebook') || admin
      userdata['fbid'] = self.fbid
      userdata['fbcover'] = self.fbcover
    end
    if scopes.include?('friends') || admin
      if admin
        userdata['friends'] = self.friends.select(:id, :name, :mobile, :email, :fbid, :gender, :student_id, :identity, :admission_year, :admission_department_code, :department_code, :fblink, :fbcover).map { |f| {id: f[:id], uid: f[:id], name: f[:name], email: f[:email], fbid: f[:fbid], gender: f[:gender], student_id: f[:student_id], identity: f[:identity], admission_year: f[:admission_year], admission_department_code: f[:admission_department_code], department_code: f[:department_code], fblink: f[:fblink], fbcover: f[:fbcover], mobile_verified: f.mobile? } }
      else
        userdata['friends'] = self.friends.select(:id, :name, :mobile).map { |f| {id: f[:id], uid: f[:id], name: f[:name], mobile_verified: f.mobile? } }
      end
    end
    if scopes.include?('profile') || admin
      userdata['brief'] = self.brief
    end
    if admin
      userdata['settings'] = settings.get_all
      userdata = userdata.merge(self.attributes)
    end
    userdata
  end

  def api_send_sms(message, application_id, scopes=[], admin=false)
    if scopes.include?('sms') || admin  # 有發送權
      if OauthApplicationData.get(application_id).sms_quota > 0  # 發送額度內
        if self.mobile? && self.mobile.to_s != ''  # 可被接收
          data = OauthApplicationData.get(application_id)
          data.sms_quota -= 1
          data.save
          nexmo = Nexmo::Client.new(key: Setting.nexmo_key, secret: Setting.nexmo_secret)
          begin
            nexmo.send_message(from: Setting.site_name, to: self.mobile.tr('^0-9', ''), type: "unicode", text: message)
          rescue
            return {:error => {:message => "Send error", :code => 503}, :status => 503}
          end
        else
          return {:error => {:message => "User has no mobile number", :code => 404}, :status => 404}
        end
      else
        return {:error => {:message => "Too many requests", :code => 429}, :status => 429}
      end
    else
      return {:error => {:message => "Not authorized", :code => 401}, :status => 401}
    end
    return {:success => {:message => "Ok", :code => 200}, :status => 200}
  end

  protected

  def send_confirmation_notification?
    false
  end
end
