class Api::V1::UserApiController < ApplicationController
  before_action :find_app
  before_action :check_permissions, only: [:user_data, :send_sms]
  respond_to     :json
  protect_from_forgery

  swagger_controller :user, "使用者存取相關 API"

  swagger_api :user_data do
    summary "取得指定使用者資料"
    notes "透過 access token 取得其擁有者的基本資料。需要 offline_access 權限，回傳資料因 access token 的 scope 而異。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "使用者 ID"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def user_data
    if !User.where('id = ?', params['id']).first
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    else

      t = @app.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if @is_admin
        scopes = ['admin']
      else
        scopes = t.scopes
      end
        render json: User.find(params['id'].tr('^0-9', '')).api_get_data(scopes, @is_admin)
    end
  end

  swagger_api :send_notification do
    summary "傳送通知給指定使用者"
    notes "傳送通知給 access token 擁有者。需要 notification 與 offline_access 權限。"
    param :form, :application_id, :string, :required, "應用程式 ID"
    param :form, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "使用者 ID"
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

  def send_notification
    u = User.where('id = ?', params['id']).first
    if u
      a = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
      t = a.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if (t.scopes.include?('notification') && t.scopes.include?('offline_access')) || is_admin?  # 有發送權
        respond = {:success => {:message => "Ok", :code => 200}, :status => 200}
        begin
          params[:sender] = nil
          params[:sender_url] = nil
          raise 'error' if !u.send_notification(params[:title], params[:type], params[:content], params[:url], params[:image], a.id, params[:priority], params[:importance], params[:sender], params[:sender_url], params[:icon], params[:event_name], params[:datetime], params[:location])
        rescue
          respond = {:error => {:message => "Error (User not found?)", :code => 404}, :status => 404}
        end
      else
        respond = {:error => {:message => "Not authorized", :code => 401}, :status => 401}
      end
      render json: respond, status: respond[:status]
    else
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    end
  end

  swagger_api :send_sms do
    summary "傳送簡訊給指定使用者"
    notes "傳送簡訊到 access token 擁有者的手機號碼 (若已認證)。需要 sms 與 offline_access 權限。"
    param :form, :application_id, :string, :required, "應用程式 ID"
    param :form, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "使用者 ID"
    param :form, :message, :string, :required, "簡訊內文"
    response :unauthorized
    response :too_many_requests, 'Too Many Requests 超出發送量限制'
    response :not_found, 'Not Found 沒有此使用者，或該使用者沒有填寫手機號碼'
    response :service_unavailable, 'Service Unavailable 簡訊無法送出'
    response :unauthorized
  end

  def send_sms
    if !User.where('id = ?', params['id']).first
      render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
    else

      t = @app.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if @is_admin
        scopes = ['admin']
      else
        scopes = t.scopes
      end
      respond = User.find(params['id'].tr('^0-9', '')).api_send_sms(params['message'], @app.id, scopes, @is_admin)
      render json: respond, status: respond[:status]
    end
  end


  swagger_api :rfid_scan do
    summary "RFID 查找使用者"
    notes "以 (學生證) RFID tag ID 查找使用者。僅限 admin 與特別授權的應用程式使用。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :path, :id, :integer, :required, "RFID tag ID"
    response :not_found
    response :unauthorized
  end

  def rfid_scan
    if @app.data.allow_use_of_user_rfid || @is_admin
      rfid_data = UserRfidData.find_by_code(params[:id])
      if !!rfid_data
        user = UserRfidData.find_by_code(params[:id]).user
        if !!user
          render json: user.api_get_data(['public', 'school'], false)
        else
          render json: { sid: rfid_data.sid, student_id: rfid_data.sid }
        end
        # if @is_admin
        #   render json: user, status: 200
        # else
        #   render json: user.select { |k, v| ['id', 'name'].include? k }, status: 200
        # end
      else
        render json: {:error => {:message => "User not found", :code => 404}, :status => 404}, status: 404
      end
    else
      render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
    end
  end


  swagger_api :list_users do
    summary "列出使用者"
    notes "僅供 admin 使用。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :path, :admission_year, :string, :required, "入學年，數字或 'all'"
    # param :path, :college_code, :string, :required, "學院 CODE，或 'all'"
    param :path, :department_code, :string, :required, "系所 CODE，或 'all'"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def list_users
    if @is_admin
      begin
        # if params[:college_code] == 'all'
          if params[:department_code] == 'all'
            users = User
          else
            users = Department.where("code = ?", params[:department_code]).first.students
          end
        # else
        #   if params[:department_code] == 'all'
        #     users = College.where("code = ?", params[:college_code]).first.students
        #   else
        #     users = College.where("code = ?", params[:college_code]).first.departments.where("code = ?", params[:department_code]).first.students
        #   end
        # end
        if params[:admission_year] == 'all'
          result = users.confirmed.all.select(:id, :name, :email, :admission_year, :department_code)
        else
          result = users.confirmed.where("admission_year = ?", params[:admission_year]).all.select(:id, :name, :email, :admission_year, :department_code)
        end
        render json: result
      rescue
        render json: {:error => {:message => "Not found", :code => 404}, :status => 404}, status: 404
      end
    else
      render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
    end
  end

  swagger_api :find_user do
    summary "條件尋找使用者"
    notes "僅供 admin 使用。尋找條件參數擇一填寫。"
    param :query, :application_id, :string, :required, "應用程式 ID"
    param :query, :secret, :string, :required, "應用程式密鑰"
    param :query, :fbid, :string, :optional, "Facebook ID"
    param :query, :sid, :string, :optional, "學號"
    param :query, :name, :string, :optional, "名稱"
    param :query, :email, :string, :optional, "email"
    response :unauthorized
    response :not_found, 'Not Found 沒有此使用者'
  end

  def find_user
    if @is_admin
      begin
        if params[:fbid].to_s != ''
          result = User.confirmed.where(fbid: params[:fbid]).all
        elsif params[:sid].to_s != ''
          result = User.confirmed.where(student_id: params[:sid]).all
        elsif params[:name].to_s != ''
          result = User.confirmed.where(name: params[:name]).all
        elsif params[:email].to_s != ''
          result = User.confirmed.where(email: params[:email]).all
        end

        raise 'Not found' if !result || result.count == 0

        render json: result
      rescue
        render json: {:error => {:message => "Not found", :code => 404}, :status => 404}, status: 404
      end
    else
      render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
    end
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def find_app
    if (params['application_id'].to_s == '' || params['secret'].to_s == '')
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end
    @app = Doorkeeper::Application.where(["uid = ? and secret = ?", params['application_id'].tr('^A-Za-z0-9', ''), params['secret'].tr('^A-Za-z0-9', '')]).first
    if !@app
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end
    @is_admin = false
    if @app.admin_app?
      @is_admin = true
    end
  end

  def check_permissions
    if (params['application_id'].to_s == '' || params['secret'].to_s == '')
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end

    if @app
      t = @app.access_tokens.where('resource_owner_id = ?', params['id'].tr('^0-9', '')).order('created_at DESC').first
      if t && !t.revoked_at && t.scopes.include?('offline_access')
        return true
      elsif @is_admin
        return true
      else
        render json: {:error => {:message => "Not authorized", :code => 401}, :status => 401}, status: 401
        return false
      end
    else
      render json: {:error => {:message => "Bad application ID or secret", :code => 401}, :status => 401}, status: 401
      return false
    end
  end
end
