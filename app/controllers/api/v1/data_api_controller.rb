class Api::V1::DataApiController < ApplicationController
  respond_to :json
  before_filter :set_access_control_allow_headers
  protect_from_forgery

  swagger_controller :data, "公開資料集 API"

  swagger_api :colleges do
    summary "學院代碼"
    notes "取得學院及代碼資料。"
  end

  def colleges
    render json: College.get_data
  end

  swagger_api :departments do
    summary "系所代碼"
    notes "取得系所及代碼資料。"
  end

  def departments
    render json: Department.get_data
  end

  swagger_api :site_data do
    summary "本站資料"
    notes "本站資料。"
  end

  def site_data
    data = {}

    data.merge! Hash[Setting.select_by_keys(select_settings).map { |k, v| [k.gsub('app', 'site'), v] }]

    data.merge! Hash[Preference.get_all.select_by_keys(select_preferences).map { |k, v| [k.gsub('app', 'site'), v] }]

    data['site_navigation'] = SiteNavigation.nav
    data['site_menu'] = SiteNavigation.menu

    data['colleges_data'] = College.get_data
    data['departments_data'] = Department.get_data

    render json: data
  end

  swagger_api :site_navigation do
    summary "本站導航"
    notes "子網站導航。"
  end

  def site_navigation
    render json: SiteNavigation.nav
  end

  swagger_api :site_menu do
    summary "本站選單"
    notes "子網站選單。"
  end

  def site_menu
    render json: SiteNavigation.menu
  end

  private

  def select_settings
    [
      'site_name',
      'app_domain',
      'app_url',
      'org_name',
      'administrator_url',
      'administrator_email',
      'mailer_sender',
      'google_analytics_id',
    ]
  end

  def select_preferences
    [
      'app_logo',
      'page_footer',
      'fb_page',
      'site_announcement',
      'maintenance_mode',
      'administrator_url',
      'administrator_email',
      'mailer_sender',
      'google_analytics_id',
    ]
  end
end
