#!/usr/bin/env ruby
# coding:utf-8
require 'socket'
require 'yaml'
require 'net/http'

require_relative './app/lib/shogi_client'
#
#クライアント設定ファイルの読み込み
config_file_name = ARGV[0]
config = YAML.load_file(config_file_name)

#クライアントのインスタンス化
client = Shogi_client.new(config['client_name'], config['client_mode'], config['thinkengine'])

#クライアントオブジェクトに対して、サーバー処理
sock = TCPSocket.open(config['server_name'], config['port'])

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

#agent 設定ファイル

agent_config = YAML.load_file('./agent_config.yaml')

 
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
      uri = URI.parse "http://#{agent_config['viewer_server_name']}:#{agent_config['viewer_server_port']}/newgame"
      req = Net::HTTP::Get.new uri.path
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request req }
  end

  if(c == '#LOSE' || c == '#WIN')
    sock.write("LOGOUT\n")
    break
  end
  if(client.status == 'TAIKYOKU' && c =~ /^(\+|\-)(\d\d\d\d.+),(T\d+)$/)
    

    if($1 != client.game_summary['Your_Turn'])

      # $1-$4からURI生成し、shogi_vewer へHTTPリクエスト
      uri = URI.parse "http://#{agent_config['viewer_server_name']}:#{agent_config['viewer_server_port']}/data_receive/"
      req = Net::HTTP::Post.new uri.path
      params = {sasite: c}
      req.set_form_data(params)
      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request req }

      puts "[log:#{client.name}:my turn]"
      next_move = client.next_move("#{$1}#{$2}")
      if( next_move =~ /^%/)
        sendmessage = next_move
      else
        sendmessage = client.game_summary['Your_Turn'] + "#{next_move}" 
      end
      sock.write(sendmessage + "\n")
      puts "[log:#{client.name}:#{sendmessage}:turn end]"
    end
  end
end
sock.close

