require 'yaml'
$settings = YAML.load_file('settings.yml') rescue {}
raise Exception.new('settings.yml not defined') if $settings.blank?

$TRIVIA = nil

($COMMAND_KEYWORDS ||= []) << '@trivia'
($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args|
  node = args[:node]
  ch_index = args[:ch_index]
  params_str = args[:params_str]
  payload = args[:payload]
  $TRIVIA = Trivia.new(ch_index: ch_index, max_questions: params_str).start if /^@trivia/i =~ payload
  next nil if $TRIVIA.nil?
  $TRIVIA.score(node) if /^@score|@points$/i =~ payload
  $TRIVIA.hint(node) if /^@hint|@clue$/i =~ payload
  $TRIVIA.skip if /^@next|@skip$/i =~ payload
  $TRIVIA.answer(node) if $TRIVIA.trivia_answer.downcase.strip == payload.downcase.strip
  nil
}

class Trivia
  attr_accessor :trivia_answer

  WINNER_RESPONSES = File.readlines("#{File.dirname(__FILE__)}/winner_responses.dat")
  TAUNT_RESPONSES = File.readlines("#{File.dirname(__FILE__)}/taunt_responses.dat")
  LOSER_RESPONSES = File.readlines("#{File.dirname(__FILE__)}/loser_responses.dat")
  INCORRECT_CH_INDEX_MSG = $settings['trivia']['incorrect_ch_index_msg'].presence || 'Trivia cannot be played on this channel.'

  def initialize(options)
    @ch_index = options[:ch_index]
    @max_questions = options[:max_questions].present? && options[:max_questions].to_i > 0 ? options[:max_questions].to_i : ($settings['trivia']['default_max_questions'].presence || 25)
    @question_number = 0
  end

  def start
    if $TRIVIA.present?
      $message_transmitter.transmit(message: 'Trivia is already running!', ch_index: @ch_index)
      return nil
    end
    if @ch_index.to_i != $settings['trivia']['ch_index']
      $message_transmitter.transmit(message: Trivia::INCORRECT_CH_INDEX_MSG, ch_index: @ch_index)
      return nil
    end
    @question_number = 0
    TriviaProfile.delete_all
    $message_transmitter.transmit(message: 'New trivia game is about to start!', ch_index: @ch_index)
    $message_transmitter.transmit(message: "The player with the most number of points after #{@max_questions} questions wins!", ch_index: @ch_index)
    new_question
    self
  end

  def score(node)
    points = node.trivia_profile.try(:points) || 0
    $message_transmitter.transmit(message: "Your score in trivia is currently: #{points}", ch_index: @ch_index)
    self
  end

  def hint(node)
    clue = 'x' * @trivia_answer.length
    clue[0] = @trivia_answer[0]
    clue[1] = @trivia_answer[1]
    clue[2] = @trivia_answer[2]
    cost = (@trivia_answer.length / 2.0).round
    $message_transmitter.transmit(message: "You have purchased a clue for #{cost} points.", ch_index: @ch_index)
    $message_transmitter.transmit(message: "Clue: #{clue}", ch_index: @ch_index)
    trivia_profile = TriviaProfile.where(node_id: node.id).first_or_initialize
    trivia_profile.points -= cost
    trivia_profile.save
    self
  end

  def skip
    @trivia_answer = nil
    $TAUNT_THREAD.exit if !$TAUNT_THREAD.nil? && $TAUNT_THREAD.alive?
    $TIMES_UP_THREAD.exit if !$TIMES_UP_THREAD.nil? && $TIMES_UP_THREAD.alive?
    $message_transmitter.transmit(message: 'Question skipped!', ch_index: @ch_index)
    new_question
    self
  end

  def answer(node)
    trivia_answer = @trivia_answer
    @trivia_answer = nil
    $TAUNT_THREAD.exit if !$TAUNT_THREAD.nil? && $TAUNT_THREAD.alive?
    $TIMES_UP_THREAD.exit if !$TIMES_UP_THREAD.nil? && $TIMES_UP_THREAD.alive?
    trivia_profile = TriviaProfile.where(node_id: node.id).first_or_initialize
    trivia_profile.points += trivia_answer.length
    trivia_profile.save
    $message_transmitter.transmit(message: "#{Trivia::WINNER_RESPONSES.sample} #{node.name} got the answer right!", ch_index: @ch_index)
    $message_transmitter.transmit(message: "You now have #{trivia_profile.points} point(s)", ch_index: @ch_index)
    new_question
    self
  end

  def new_question
    @question_number += 1
    if @question_number <= @max_questions
      $message_transmitter.transmit(message: "Get ready for question ##{@question_number}!", ch_index: @ch_index)
    else
      @trivia_answer = nil
      $TRIVIA = nil
      $message_transmitter.transmit(message: 'GAME OVER!! Preparing the results...', ch_index: @ch_index)
      trivia_profiles = TriviaProfile.order('points desc')
      $message_transmitter.transmit(message: 'Hmm... It looks like no one scored this round. Lol.  Better luck next time!', ch_index: @ch_index) if trivia_profiles.empty?
      trivia_profiles.each_with_index do |trivia_profile, i|
        node = trivia_profile.node
        name = node.name
        case i
          when 0 then $message_transmitter.transmit(message: "[1st Place]: #{name} with #{trivia_profile.points} points", ch_index: @ch_index)
          when 1 then $message_transmitter.transmit(message: "[2nd Place]: #{name} with #{trivia_profile.points} points", ch_index: @ch_index)
          when 2 then $message_transmitter.transmit(message: "[3rd Place]: #{name} with #{trivia_profile.points} points", ch_index: @ch_index)
        end
      end
      $message_transmitter.transmit(message: 'To play again, say @trivia', ch_index: @ch_index)
      return
    end
    @trivia_question, @trivia_answer = File.readlines("#{File.dirname(__FILE__)}/trivia.dat").sample.split('*')
    @trivia_question.strip!
    @trivia_answer.strip!
    $log_it.log "TRIVIA_QUESTION = #{@trivia_question} | TRIVIA_ANSWER = #{@trivia_answer}", :green
    $message_transmitter.transmit(message: "For #{@trivia_answer.length} points, #{@trivia_question}", ch_index: @ch_index)
    $TAUNT_THREAD = Thread.new {sleep 60;$message_transmitter.transmit(message: Trivia::TAUNT_RESPONSES.sample, ch_index: @ch_index)}
    $TIMES_UP_THREAD = Thread.new {sleep 120;$message_transmitter.transmit(message: "#{Trivia::LOSER_RESPONSES.sample}: #{@trivia_answer}", ch_index: @ch_index);new_question}
    self
  end
end
