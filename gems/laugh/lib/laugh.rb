($TEXT_MESSAGE_HANDLERS ||= []) << Proc.new {|args| Laugh.new.msg if /^(hah|lol|lmao|heh)/i =~ args[:payload]}
class Laugh
  def initialize
  end

  def msg
    laughs = [
      "HAHAHA!@$^%!@",
      'LMAO!',
      'KeOkEoKeOkEok!!!',
      'LOL!!',
      'MUAHAHAHA!!',
      'heh...',
      'HEH!',
      'HEHE!!',
      ';/',
      ';P'
    ]
    laughs += ['']*laughs.length
    laughs << 'HO! HO! HO!' if Time.now.strftime('%m') == '12'
    laughs.sample
  end
end
