class UsersController < ApplicationController
  before_filter :set_access_control_allow_headers, only: [:show]

  def show
    @user = User.confirmed.where(id: params[:id]).first
    redirect_to "/users/#{@user.username}" if @user && !@user.username.blank? && params['format'].to_s != 'json'
    @user = User.where("lower(username) = ?", params[:id].downcase).first if !@user
    raise ActionController::RoutingError.new('User Not Found') if !@user

    @relationship = 'none'
    if current_user
      if @user.id == current_user.id
        @relationship = 'me'
      elsif @user.friends.include?(current_user)
        @relationship = 'friends'
      elsif true
        @relationship = 'school'
      end
    end

    @data = []
    case @user.school_data_privacy
      when 'public'
        @data << 'school_data'
      when 'friends'
        @data << 'school_data' if @relationship == 'friends'
      when 'school'
        @data << 'school_data' if @relationship == 'school'
      else
        @data << 'school_data' if @relationship == 'me'
    end
    case @user.information_privacy
      when 'public'
        @data << 'information'
      when 'friends'
        @data << 'information' if @relationship == 'friends'
      when 'school'
        @data << 'information' if @relationship == 'school'
      else
        @data << 'information' if @relationship == 'me'
    end
    case @user.activity_privacy
      when 'public'
        @data << 'activity'
      when 'friends'
        @data << 'activity' if @relationship == 'friends'
      when 'school'
        @data << 'activity' if @relationship == 'school'
      else
        @data << 'activity' if @relationship == 'me'
    end
  end

  def new
    if session["devise.new_user_time"] && session["devise.new_user_time"] > 600.seconds.ago && session["devise.new_user_id"]
      if @user = User.where(confirmed_at: nil, id: session["devise.new_user_id"]).first
        @user.email = @user.unconfirmed_email if @user.email =~ /@dev\.null$/
      else
        redirect_to root_path
      end
    else
      flash[:alert] = "session 已過期。"
      redirect_to root_path
    end
  end

  def new_update
    # start hack on devise translate
    I18n.backend.store_translations('zh-TW', {
      devise: {
        mailer: {
          confirmation_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.confirmation_instructions.subject')
          },
          reset_password_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.reset_password_instructions.subject')
          },
          unlock_instructions: {
            subject: Setting.site_name + " " + I18n.backend.translate('zh-TW', 'devise.mailer.unlock_instructions.subject')
          }
        }
      },
      zhTW_devise_mailer_confirmation_instructions_subject: 'true'
    }) if I18n.translate('zhTW_devise_mailer_confirmation_instructions_subject') != "true"
    # end hack on devise translate

    if session["devise.new_user_id"]
      session["devise.new_user_time"] = Time.now
      @user = User.where(confirmed_at: nil, id: session["devise.new_user_id"]).first
      email = params['user']['email']
      email.downcase!
      if email =~ Setting.email_regexp
        if @user.update_attribute(:email, email)
          data = Setting.email_analysis_regexp.match(email)
          data = Hash[data.names.zip(data.captures)]
          if data
            identities = { b: 'bachelor', m: 'master', d: 'doctor' }
            @user.identity = data.has_key?('identity_id') ? identities[data['identity_id'].to_sym] : 'other'
            @user.admission_year = data['admission_year'].to_i if data.has_key?('admission_year')
            if data.has_key?('admission_department_code') && !!Department.where(code: data['admission_department_code'].to_s).first
              @user.admission_department_code = data['admission_department_code'].to_s
              @user.department_code = data['admission_department_code'].to_s
            end
            @user.student_id = data['student_id'] if data.has_key?('student_id')
          else
            @user.identity = 'other'
            @user.admission_year = nil
            @user.admission_department_code = nil
            @user.department_code = nil
            @user.student_id = email.gsub(/@.*$/, '')
          end
            @user.save
          # @user.send_confirmation_instructions # this will be done automatically
          @user.send_confirmation_instructions if @user.email == @user.unconfirmed_email
          # ...but just in case of this happens ↗
          flash[:success] = "認證信已送出！"
          redirect_to users_new_path
        else
          flash[:alert] = "認證信發送失敗，請再試一次，若問題持續發生，請聯絡開發者。"
          redirect_to users_new_path
        end
      else
        flash[:alert] = "不合法的 email，請確認你輸入的是正確的學校 email！"
        redirect_to users_new_path
      end

    else
      flash[:alert] = "session 已過期。"
      redirect_to root_path
    end
  end

  def dev_login
    if Rails.env.development?
      @user = User.find(params[:id])
      sign_in_and_redirect @user
    end
  end
end
