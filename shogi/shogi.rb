#!/usr/bin/env ruby
# coding:utf-8

require 'socket'
class Shogi_Client
  attr_reader :client_name
  attr_reader :game_summary
  attr_accessor :client_status

  def initialize(client_name)
    @game_summary = Hash.new
    @client_name = client_name
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
end

obj = Shogi_Client.new(ARGV[0])
obj.client_status = 'BEFORE LOGIN'

sock = TCPSocket.open("localhost",4081)
sock.write("LOGIN #{obj.client_name} testgame-1500-0\n")

while(c = sock.gets.chomp!)
  puts c
  obj.set_summary(c);
  if(c == "LOGIN:#{obj.client_name} OK")
    obj.client_status = 'LOGIN'
    puts obj.client_status
  end

  if(c =~ /^START:.+/)
    obj.client_status = 'TAIKYOKU'
    puts obj.client_status
    if(obj.game_summary["Your_Turn"] == '+')
      puts "my turn"
      #先手初手を指す
      sock.write("+2726FU\n")
    end
    p obj.game_summary
  end

  if(obj.client_status == 'LOGIN' && c == "END Game_Summary")
    sock.write("AGREE\n")
    puts "AGREE"
  end

  if(obj.client_status == 'TAIKYOKU' && c == 'Your_Turn:+')
    obj.client_status = 'YOUR_TURN'
    puts obj.client_status
  end
end
sock.close


__END__
object 設計
現在のステータス　プロバティ


BEGIN Game_Summary

Protocol_Version:1.1
Protocol_Mode:Server
Format:Shogi 1.0
Declaration:Jishogi 1.1
Game_ID:testgame+testgame-1500-0+u2+u1+20150528214856
Name+:u2
Name-:u1
Your_Turn:+
Rematch_On_Draw:NO
To_Move:+

BEGIN Time

Time_Unit:1sec
Total_Time:1500
Byoyomi:0
Least_Time_Per_Move:0

END Time

BEGIN Position

P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
P2 * -HI *  *  *  *  * -KA *
  P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P4 *  *  *  *  *  *  *  *  *
  P5 *  *  *  *  *  *  *  *  *
  P6 *  *  *  *  *  *  *  *  *
  P7+FU+FU+FU+FU+FU+FU+FU+FUFU
P8 * +KA *  *  *  *  * +HI *
  P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
+
  END Position
END Game_Summary
