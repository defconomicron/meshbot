# SOURCE: https://raw.githubusercontent.com/beanboi7/yomomma-apiv2/refs/heads/master/jokes.json

($COMMAND_KEYWORDS ||=[]) << '@mom'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| YoMomma.new.msg if /^@mom/i =~ args[:payload]}
class YoMomma
  require 'csv'
  JOKES = JSON.parse(File.read("#{File.dirname(__FILE__)}/jokes.json")) rescue []

  def initialize
  end

  def msg
    YoMomma::JOKES.sample
  end
end
