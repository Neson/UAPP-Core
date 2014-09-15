module BasicUserApi
  extend ActiveSupport::Concern

  def user_data
    render json: current_resource_owner.api_get_data(@scopes)
  end

  def send_notification
    if @scopes.include?('notification') || @admin  # 有發送權
      begin
        params[:sender] = nil
        params[:sender_url] = nil
        current_resource_owner.send_notification(params[:title], {type: params[:type], content: params[:content], url: params[:url], image: params[:image], sender_application_id: @app.id, priority: params[:priority], importance: params[:importance], sender: params[:sender], sender_url: params[:sender_url], icon: params[:icon], event_name: params[:event_name], datetime: params[:datetime], location: params[:location]})
        respond = {:success => {:message => "Ok", :code => 200}, :status => 200}
      rescue
        respond = {:error => {:message => "Error (Not found?)", :code => 404}, :status => 404}
      end
    else
      respond = {:error => {:message => "Not authorized", :code => 401}, :status => 401}
    end
    render json: respond, status: respond[:status]
  end

  def send_sms
    if @scopes.include?('sms') || @admin  # 有發送權
      if @app.data.sms_quota > 0  # 發送額度內
        message = params['message']
        respond = current_resource_owner.api_send_sms(message)
        if respond[:status] == 200
          data = @app.data
          data.sms_quota -= (message.bytesize.to_f/160 + 0.5).to_i
          data.save!
        end
      else
        respond = {:error => {:message => "Too many requests", :code => 429}, :status => 429}
      end
    else
      respond = {:error => {:message => "Not authorized", :code => 401}, :status => 401}
    end
    render json: respond, status: respond[:status]
  end
end
