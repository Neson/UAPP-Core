class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    limit = 50
    page = params[:page].to_i
    show_dismissed = params[:show_dismissed].to_s == 'true' ? true : false
    @notifications = current_user.notifications.get_latest(page, limit, show_dismissed)
    @notifications_count = current_user.notifications.count
  end
end
