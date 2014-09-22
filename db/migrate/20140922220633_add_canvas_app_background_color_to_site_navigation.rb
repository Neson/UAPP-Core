class AddCanvasAppBackgroundColorToSiteNavigation < ActiveRecord::Migration
  def change
    add_column :site_navigations, :canvas_app_background_color, :string
  end
end
