#!/usr/bin/env ruby
# coding:utf-8
require 'socket'
require 'yaml'

require_relative './lib/shogi_client'
#
#クライアントクラスの読み込み
config_file_name = ARGV[0]
config = YAML.load_file(config_file_name)

#クライアントのインスタンス化
client = Shogi_client.new(config['client_name'], config['client_mode'], config['thinkengine'])

#クライアントオブジェクトに対して、サーバー処理
sock = TCPSocket.open(config['server_name'], config['port_no'])

client.status = 'BEFORE_LOGIN'

if (client.mode == 'x1')
  sock.write("LOGIN #{client.name} password x1\n")
  puts 'x1'
else
  sock.write("LOGIN #{client.name}  testgame-1500-0\n")
  puts 'csa'
end

# client_status
# BEFORE_LOGIN
# LOGIN
# TAIKYOKU
 
while(c = sock.gets.chomp!)
  puts "[log:#{client.name}:recive message:#{c}]"
  client.set_summary(c);
  if(c == "LOGIN:#{client.name} OK")
    client.status = 'LOGIN'
    puts client.status
  end

  if(c =~ /^START:.+/)
    client.status = 'TAIKYOKU'
    puts client.status
    if(client.game_summary['Your_Turn'] == '+')
      puts "[log:#{client.name}:my turn]"
      #先手初手を指す
      next_move = client.next_move('-')
      sendmessage = client.game_summary['Your_Turn'] + "#{next_move}" 
      sock.write(sendmessage + "\n")
      puts "[log:#{client.name}:#{sendmessage}:turn end]"
    else
      client.game_summary['Your_Turn'] = '-'
    end
    p client.game_summary
  end

  if(client.status == 'LOGIN' && c == 'END Game_Summary')
    sock.write("AGREE\n")
    puts 'AGREE'
  end

  if(client.status == 'TAIKYOKU' && c =~ /^(\+|\-)(.+),(T\d+)$/)
    if($1 != client.game_summary['Your_Turn'])
      puts "[log:#{client.name}:my turn]"
      next_move = client.next_move("#{$1}#{$2}")
      sendmessage = client.game_summary['Your_Turn'] + "#{next_move}" 
      sock.write(sendmessage + "\n")
      puts "[log:#{client.name}:#{sendmessage}:turn end]"
    end
  end
end
sock.close

