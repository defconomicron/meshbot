($COMMAND_KEYWORDS ||=[]) << '@resolve'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| UrlResolver.new(args[:params_str]).resolve if /^@resolve/i =~ args[:payload]}
require 'embiggen'
class UrlResolver
  def initialize(url)
    @url = url
  end

  def resolve
    return 'A URL must be provided with your request.  Example: @resolve https://goo.gl' if @url.blank?
    Embiggen::URI(@url).expand.to_s
  end
end