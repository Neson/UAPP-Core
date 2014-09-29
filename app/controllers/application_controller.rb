class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :check_url, :set_logger
  before_filter :get_app_setting
  before_action :save_page_history
  after_action :login_control

  def doorkeeper_unauthorized_render_options
    {:json => {:error => {:message => "Not authorized", :code => 401}}}
  end

  private

  def check_url
    if !request.original_url.match(/#{Setting.app_url.gsub(/\/$/, '')}/)
      @canvas_app = SiteNavigation.canvas_app_with_url(request.original_url.get_domain_from_url).first
      if !!@canvas_app
        render_canvas_app
      elsif Rails.env.production?
        redirect_to(Setting.app_url.gsub(/\/$/, '') + request.fullpath) && return
      end
    end
  end

  def render_canvas_app
    set_page_title @canvas_app.canvas_app_title
    set_page_description @canvas_app.canvas_app_description
    set_page_image @canvas_app.canvas_app_image
    render 'pages/canvas_app'
  end

  def set_logger
    Rails.logger = Rails.application.config.logger if !!Rails.application.config.logger
  end

  def get_app_setting
    # The settings are loaded with '/app/models/setting.rb'
    @app_name = Setting.app_name
    @google_analytics_id = Setting.google_analytics_id
    Setting['email_regexp'] = /#{Setting.email_regexp_s}/
    Setting['email_analysis_regexp'] = /#{Setting.email_analysis_regexp_s}/
  end

  def save_page_history
    (session[:page_history] ||= []).unshift request.fullpath
    session[:page_history].pop if session[:page_history].length > 4
  end

  def login_control
    if current_user
      current_user.write_login_token_to_cookie(cookies)
    else
      cookies[:login_token] = { value: '', domain: '.' + Setting.app_domain }
    end
  end

  def set_access_control_allow_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def block_foreign_request_referrers
    if !request.referrer.blank?
      request_referrer_domain = Addressable::URI.parse(request.referrer).host
      if !!request_referrer_domain.match(/#{Setting.app_domain}$/)
        render json: {:error => {:message => "Request rejected from URL: #{request.referrer} (not a sub-domain of #{Setting.app_domain}).", :code => 403}, :status => 403}, status: 403
      end
    end
  end
end
