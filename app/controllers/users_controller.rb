class UsersController < ApplicationController
  before_filter :set_access_control_allow_headers, only: [:show]
  before_action :get_user, only: [:show]
  before_action :get_relationship_and_data_set, only: [:show]

  def get_user
    @user = User.confirmed.where(id: params[:id]).first
  end

  def get_relationship_and_data_set
    @relationship = (!!current_user ? @user.relationship_with(current_user) : 'none')

    @data = []
    ['school_data', 'information', 'activity'].each do |privacy_type|
      case @user["#{privacy_type}_privacy"]
        when 'public'
          @data << privacy_type
        when 'friends'
          @data << privacy_type if @relationship == 'friends'
        when 'school'
          @data << privacy_type if @relationship == 'school'
        else
          @data << privacy_type if @relationship == 'me'
      end
    end
  end

  def show
    if params['format'].to_s != 'json'
      redirect_to "/users/#{@user.username}" if @user && !@user.username.blank?
    end
    @user = User.where("lower(username) = ?", params[:id].downcase).first if !@user
    raise ActionController::RoutingError.new('User Not Found') if !@user
  end

  def dev_login
    if Rails.env.development?
      @user = User.find(params[:id])
      sign_in_and_redirect @user
    end
  end
end
