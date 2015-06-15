class Shogi_client
  #固有インスタンス変数
  attr_accessor :name
  attr_accessor :status
  attr_accessor :mode

  #サーバー戻り値ステータス変数
  attr_reader :game_summary
  attr_reader :engine

  def initialize(name, mode, engine)
    @name = name
    if(mode == 'x1')
      @mode = 'advance'
    else
      @mode = 'csa'
    end
    @status = 'BEFORE LOGIN'
    @engine = engine

    if(engine == 'kifu')
      require_relative 'engine_kifu'
      @engine_object = Engine_kifuread.new
    else

    end

    @status = Hash.new

    @game_summary = Hash.new
  end

  def set_summary(recievelog)
    if(recievelog =~ /^(BEGIN|END)/)
      return
    elsif(recievelog =~ /^(.+):(.+)$/)
      $1[0].downcase!
      @game_summary[$1] = $2
    else
      return
    end
  end


  #指し手メソッド
  def next_move(opp_move)
    case @engine
    when 'test'
      nextmove = '2726FU'
    when 'kifu'
      nextmove = @engine_object.get_sasite(opp_move)
    end
    return nextmove 
  end
end

__END__
