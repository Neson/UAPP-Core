module CodeAndName
  extend ActiveSupport::Concern

  included do
    class_attribute :tag_limit
  end

  module ClassMethods

    def get_data
      update_cache if !Rails.cache.read("site_#{self.name.downcase}")
      Rails.cache.read("site_#{self.name.downcase}")
    end

    def update_cache
      data = all.select('code', 'name').order('code ASC').map do |hash|
        hash.attributes.select { |k, v| ['code', 'name'].include? k }
      end

      Rails.cache.write("site_#{self.name.downcase}", data)
    end

  end
end
