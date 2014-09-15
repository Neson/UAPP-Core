class Hash

  def select_by_keys(keys=[])
    self.select { |k, v| keys.include? k }
  end
end
