ActiveAdmin.register Doorkeeper::Application do
  menu priority: 50, label: "應用程式", parent: "應用程式"

  permit_params :name, :redirect_uri

  index do
    selectable_column
    id_column
    column :name do |app|
      link_to app.name, admin_doorkeeper_application_path(app)
    end
    column :owner_type do |app|
      if app.owner_type == 'User'
        if app.owner && app.owner.admin?
          status_tag('Admin User', :class => 'Admin User')
        else
          status_tag('User', :class => 'User')
        end
      else
        status_tag(app.owner_type, :class => app.owner_type)
      end
    end
    column :owner
    column :redirect_uri
    column :created_at
    column :sms_quota do |app|
      data = OauthApplicationData.get(app.id)
      link_to data.sms_quota, (admin_oauth_application_data_path() + '/' + data.id.to_s)
    end
    column :rfid do |app|
      if app.owner_type != 'Admin'
        if app.data.allow_use_of_user_rfid
          status_tag('Yes', :class => 'yes')
        else
          status_tag('No', :class => 'no')
        end
      else
        status_tag('(Admin)', :class => 'yes')
      end
    end
    actions
  end

  form do |f|
    f.inputs "App Details" do
      f.input :name
      f.input :redirect_uri
    end
    f.actions
  end

  scope :all
  scope :admin_apps, :default => true
  scope :user_apps

  controller do

    def update
      @application = Doorkeeper::Application.find(params[:id])
      @application.name = params[:application] && params[:application][:name]
      @application.redirect_uri = params[:application] && params[:application][:redirect_uri]
      if @application.save
        redirect_to admin_doorkeeper_application_path(@application)
      else
        redirect_to :back
      end
    end

    def create
      @application = Doorkeeper::Application.new
      @application.name = params[:application] && params[:application][:name]
      @application.redirect_uri = params[:application] && params[:application][:redirect_uri]
      @application.owner = current_admin
      @application.owner_type = 'Admin'
      if @application.save
        redirect_to admin_doorkeeper_application_path(@application)
      else
        redirect_to :back
      end
    end
  end
end
