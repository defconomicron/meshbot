($COMMAND_KEYWORDS ||= []) << '@poop'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Poop.new(args[:params_str]).msg if /^@poop/i =~ args[:payload]}
class Poop
  def initialize(quantity)
    @quantity = quantity.present? ? quantity.to_i : 1
  end

  def msg
    '💩' * @quantity
  end
end