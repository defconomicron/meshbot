Time.class_eval do
  def human
    strftime("%m-%d-%Y %I:%M:%S %p")
  end
end