ActiveAdmin.register SiteNavigation do
  menu priority: 80, label: "網站選單"
  config.sort_order = "priority_asc"

  permit_params :url, :name, :icon, :description, :color, :priority, :show_in_navigation, :show_in_menu, :enabled, :cross_domin, :canvas_app, :canvas_app_title, :canvas_app_description, :canvas_app_image, :canvas_app_url, :canvas_app_background_color

  index do
    selectable_column
    # id_column
    column :priority
    column :name do |item|
      link_to item.name, admin_site_navigation_path(item)
    end
    column :url
    column :color
    column :enabled
    column :show_in_navigation
    column :show_in_menu
    column :cross_domin
    column :canvas_app
    actions
  end
end
