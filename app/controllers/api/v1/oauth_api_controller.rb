class Api::V1::OauthApiController < ApplicationController
  include BasicUserApi
  doorkeeper_for :all
  respond_to     :json
  before_filter :set_access_control_allow_headers
  protect_from_forgery

  swagger_controller :users, "OAuth 2.0 User 相關 API"

  before_action :authenticate

  swagger_api :me do
    summary "取得使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。回傳資料因 access token 的 scope 而異。"
    param :query, :access_token, :string, :required, "access token"
    response :unauthorized
  end

  def me
    render json: current_resource_owner.api_get_data(@scopes)
  end

  swagger_api :send_notification do
    summary "傳送通知"
    notes "傳送通知給 access token 擁有者。需要 notification 權限。"
    param :form, :access_token, :string, :required, "access token"
    param :form, :title, :string, :required, "通知標題"
    param :form, :type, :string, :optional, "通知類型"
    param :form, :content, :string, :optional, "通知內文"
    param :form, :url, :string, :optional, "通知連結網址"
    param :form, :priority, :integer, :optional, "通知急迫性，1 緊急 ~ 3 不緊急，0 代表非常緊急，若使用者有設定將此類通知轉發簡訊，將會送出簡訊並扣除簡訊額度 (轉發簡訊功能未實作)"
    param :form, :importance, :integer, :optional, "通知重要性，1 重要 ~ 3 不重要，0 將會置頂直到使用者進行動作"
    param :form, :image, :string, :optional, "圖片"
    # param :form, :sender, :string, :optional, "傳送者名稱，預設為應用程式名稱"
    # param :form, :sender_url, :string, :optional, "傳送者網址，預設為應用程式網址"
    param :form, :icon, :string, :optional, "圖示，預設為應用程式圖示"
    param :form, :event_name, :string, :optional, "事件名稱，配合特殊類型使用"
    param :form, :datetime, :string, :optional, "時間，配合特殊類型使用"
    param :form, :location, :string, :optional, "地點，配合特殊類型使用"
    response :unauthorized
  end

  # Defined in app/controllers/concerns/basic_user_api.rb

  swagger_api :send_sms do
    summary "傳送簡訊"
    notes "傳送簡訊到 access token 擁有者的手機號碼 (若已認證)。需要 sms 權限。"
    param :form, :access_token, :string, :required, "access token"
    param :form, :message, :string, :required, "簡訊內文"
    response :unauthorized
    response :too_many_requests, 'Too Many Requests 超出發送量限制'
    response :not_found, 'Not Found 該使用者沒有填寫手機號碼'
    response :service_unavailable, 'Service Unavailable 簡訊無法送出'
  end

  # Defined in app/controllers/concerns/basic_user_api.rb

  private

  def authenticate
    @app = doorkeeper_token.application
    @scopes = doorkeeper_token.scopes.all
    if @app.admin_app?
      @admin = true
      @scopes << 'admin'
    else
      @admin = false
      @scopes.delete('admin')
    end
    @scopes = [] if @scopes == nil
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
