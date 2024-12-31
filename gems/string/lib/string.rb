String.class_eval do
  def truncate(max)
    length > max ? "#{self[0...max]}..." : self
  end
  def is_integer?
    self.to_i.to_s == self
  end
end