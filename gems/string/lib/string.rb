String.class_eval do
  def truncate(max)
    length > max ? "#{self[0...max]}..." : self
  end
end