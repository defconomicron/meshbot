($COMMAND_KEYWORDS ||=[]) << '@trivia'
$TRIVIA = nil
$QUESTION_NUMBER = 0
$DEFAULT_MAX_QUESTIONS = 25
$MAX_QUESTIONS = 25

($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args|
  trivia_answer = $TRIVIA_ANSWER

  if /^@trivia/i =~ args[:payload]
    if args[:channel] != 3
      $tx_bot.send_text('To play trivia, you must first join the channel named "Trivia" with a PSK of "AQ=="', args[:channel])
      next nil
    end
    if $TRIVIA.present?
      $tx_bot.send_text('Trivia is already running!', args[:channel])
      next nil
    end
    $TRIVIA = Trivia.new(channel: args[:channel])
    $QUESTION_NUMBER = 0
    $MAX_QUESTIONS = args[:params_str].present? && args[:params_str].to_i > 0 ? args[:params_str].to_i : $DEFAULT_MAX_QUESTIONS
    TriviaProfile.delete_all
    $tx_bot.send_text("New trivia game is about to start!", args[:channel])
    $tx_bot.send_text("The player with the most number of points after #{$MAX_QUESTIONS} questions wins!", args[:channel])
    $TRIVIA.new_question
  end

  if /^@score|@points$/i =~ args[:payload]
    if $TRIVIA.nil?
      $tx_bot.send_text("Trivia has not yet started.", args[:channel])
      next nil
    end
    node = Node.where(number: args[:from]).first_or_initialize
    points = node.trivia_profile.try(:points) || 0
    $tx_bot.send_text("Your score in trivia is currently: #{points}", args[:channel])
  end

  if /^@hint|@clue$/i =~ args[:payload]
    if $TRIVIA.nil?
      $tx_bot.send_text("Trivia has not yet started.", args[:channel])
      next nil
    end
    clue = 'x' * trivia_answer.length
    clue[0] = trivia_answer[0]
    clue[1] = trivia_answer[1]
    clue[2] = trivia_answer[2]
    cost = (trivia_answer.length / 2.0).round
    $tx_bot.send_text("You have purchased a clue for #{cost} points.", args[:channel])
    $tx_bot.send_text("Clue: #{clue}", args[:channel])
    node = Node.where(number: args[:from]).first_or_initialize
    node.save
    trivia_profile = TriviaProfile.where(node_id: node.id).first_or_initialize
    trivia_profile.points -= cost
    trivia_profile.save
  end

  if /^@next|@skip$/i =~ args[:payload]
    if $TRIVIA.nil?
      $tx_bot.send_text("Trivia has not yet started.", args[:channel])
      next nil
    end
    $TAUNT_THREAD.exit if !$TAUNT_THREAD.nil? && $TAUNT_THREAD.alive?
    $TIMES_UP_THREAD.exit if !$TIMES_UP_THREAD.nil? && $TIMES_UP_THREAD.alive?
    $TRIVIA_ANSWER = nil
    $tx_bot.send_text("Question skipped!", args[:channel])
    $TRIVIA.new_question
  end

  if trivia_answer.present? && trivia_answer.downcase.strip == args[:payload].downcase.strip
    $TAUNT_THREAD.exit if !$TAUNT_THREAD.nil? && $TAUNT_THREAD.alive?
    $TIMES_UP_THREAD.exit if !$TIMES_UP_THREAD.nil? && $TIMES_UP_THREAD.alive?
    $TRIVIA_ANSWER = nil
    node = Node.where(number: args[:from]).first_or_initialize
    node.save
    name = [node.short_name, node.long_name].select(&:present?).join(': ').presence || "Node ##{node.number}"
    trivia_profile = TriviaProfile.where(node_id: node.id).first_or_initialize
    trivia_profile.points += trivia_answer.length
    trivia_profile.save
    $tx_bot.send_text("#{Trivia::WINNER_RESPONSES.sample} #{name} got the answer right!", args[:channel])
    $tx_bot.send_text("You now have #{trivia_profile.points} point(s)", args[:channel])
    $TRIVIA.new_question
  end

  nil
}

class Trivia
  WINNER_RESPONSES = [
    'Impressive!',
    'Nice!',
    'Wow we got a genius over here!',
    'Well done!',
    'DANGER!: SMART PERSON DETECTED!',
    'Superb!',
    'WOW!',
    'Way to go!',
    'Go, you!!',
    'Boom goes the dynamite!',
    "OOooohh!! Ya'll just got dunked on!",
    'Swish!',
    'Booomm!!!',
    'You got it!',
  ]

  TAUNT_RESPONSES = [
    'Hello?',
    'Anyone? Anyone?',
    'Bueller?',
    'Anyone?',
    'Come on, you know this one.',
    'My grandma could answer this one!',
    'My newborn could answer this one.',
    'Zzz... Hello?',
    'This is the easiest question I have!',
    'Uuuuhhhh.... errmmm... hello?',
    'Lol the answer is so easy!',
    'This has to be the easiest question ever!',
    'This is a commonly asked question in 1st grade.',
    "Ya'll should know this one...",
    'The answer is so simple.'
  ]

  LOSER_RESPONSES = [
    'Bruh, the answer was',
    'Bro, the answer was',
    'Dude, the answer was',
    'Brah, the answer was',
    'Heh... The answer was',
    "Time's up! The answer was",
    'Hmmm... the answer was',
    'Hello? The answer was',
    'So sorry! The answer was',
    'So like, the answer was',
    'No..., no.. am sorry... the answer was',
    'The answer was',
  ]

  def initialize(options)
    @channel = options[:channel]
  end

  def new_question
    $QUESTION_NUMBER += 1

    if $QUESTION_NUMBER <= $MAX_QUESTIONS
      $tx_bot.send_text("Get ready for question ##{$QUESTION_NUMBER}!", @channel)
    else
      $TRIVIA = nil
      $TRIVIA_ANSWER = nil
      $tx_bot.send_text("GAME OVER!! Preparing the results...", @channel)
      trivia_profiles = TriviaProfile.order('points desc')
      $tx_bot.send_text("Hmm... It looks like no one scored this round. Lol.  Better luck next time!", @channel) if trivia_profiles.empty?
      trivia_profiles.each_with_index do |trivia_profile, i|
        node = trivia_profile.node
        name = [node.short_name, node.long_name].select(&:present?).join(': ').presence || "Node ##{node.number}"
        case i
          when 0 then $tx_bot.send_text("[1st Place]: #{name} with #{trivia_profile.points} points", @channel)
          when 1 then $tx_bot.send_text("[2nd Place]: #{name} with #{trivia_profile.points} points", @channel)
          when 2 then $tx_bot.send_text("[3rd Place]: #{name} with #{trivia_profile.points} points", @channel)
        end
      end
      $tx_bot.send_text("To play again, say @trivia", @channel)
      return
    end

    $TRIVIA_QUESTION, $TRIVIA_ANSWER = File.readlines("#{File.dirname(__FILE__)}/trivia.dat").sample.split('*')

    $TRIVIA_QUESTION.strip!
    trivia_question = $TRIVIA_QUESTION

    $TRIVIA_ANSWER.strip!
    trivia_answer = $TRIVIA_ANSWER

    $log_it.log "TRIVIA_QUESTION = #{trivia_question} | TRIVIA_ANSWER = #{trivia_answer}"
    $tx_bot.send_text("For #{trivia_answer.length} points, #{trivia_question}", @channel)

    $TAUNT_THREAD = Thread.new {
      sleep 60
      $tx_bot.send_text(Trivia::TAUNT_RESPONSES.sample, @channel)
    }

    $TIMES_UP_THREAD = Thread.new {
      sleep 120
      $tx_bot.send_text("#{Trivia::LOSER_RESPONSES.sample}: #{trivia_answer}", @channel)
      new_question
    }
  end
end
