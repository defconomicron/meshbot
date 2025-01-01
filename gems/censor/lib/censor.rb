class Censor
  BAD_WORDS = File.readlines("#{File.dirname(__FILE__)}/bad_words.txt").map {|str| str.chomp}

  def initialize(str)
    @str = str
  end

  def apply
    BAD_WORDS.each do |bad_word|
      @str = @str.gsub(/#{bad_word}/i,'*' * bad_word.length)
    end
    @str
  end
end