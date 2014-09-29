class String

  def get_domain_from_url
    self.gsub(/[^:\/]\/.*/) { |s| s.gsub(/\/.*/, '') }
  end
end
