class SiteNavigation < ActiveRecord::Base
  scope :scope_nav, -> { where('show_in_navigation = ?', true).order('priority ASC') }
  scope :scope_menu, -> { where('show_in_menu = ?', true).order('priority ASC') }
  scope :output_data, -> { select([:name, :url, :icon, :description, :color, :priority, :enabled, :cross_domin]).to_a.map { |hash| hash.attributes.select { |k, v| k != 'id' } } }
  scope :canvas_app, -> { where('canvas_app = ?', true).order('priority ASC') }

  after_save :update_cache

  def self.nav
    update_cache if !Rails.cache.read("site_navigation_nav")
    Rails.cache.read("site_navigation_nav")
  end

  def self.menu
    update_cache if !Rails.cache.read("site_navigation_menu")
    Rails.cache.read("site_navigation_menu")
  end

  def self.update_cache
    Rails.cache.write("site_navigation_nav", SiteNavigation.scope_nav.output_data)
    Rails.cache.write("site_navigation_menu", SiteNavigation.scope_menu.output_data)
  end

  def update_cache
    SiteNavigation.update_cache
  end
end
