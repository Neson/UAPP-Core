class AddCanvasAppToSiteNavigation < ActiveRecord::Migration
  def change
    add_column :site_navigations, :canvas_app, :boolean, null: false, default: false
    add_column :site_navigations, :canvas_app_url, :string
    add_column :site_navigations, :canvas_app_title, :string
    add_column :site_navigations, :canvas_app_description, :string
    add_column :site_navigations, :canvas_app_image, :string
  end
end
