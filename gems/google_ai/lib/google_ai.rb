($COMMAND_KEYWORDS ||= []) << '@ai'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| GoogleAi.new(args[:params_str]).msg if /^@ai/i =~ args[:payload]}
class GoogleAi
  def initialize(question)
    @key = $settings['google_ai']['api_key'] rescue nil
    @question = question
  end

  def msg
    return 'ERROR: Google AI API key not defined' if @key.blank?
    uri = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=#{@key}")
    header = {'Content-Type': 'text/json'}
    body = {contents: [{parts: [{text: @question}]}]}
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = body.to_json
    response = http.request(request)
    response = JSON.parse(response.body)
    response['candidates'][0]['content']['parts'][0]['text'].strip rescue 'error'
  end
end
