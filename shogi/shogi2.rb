#!/usr/bin/env ruby
# coding:utf-8

require 'socket'

client_name = ARGV
client_name.chomp!

client_status = 'BEFORE LOGIN'
sock = TCPSocket.open("localhost",4081)

sock.write("LOGIN #{client_name} testgame-1500-0\n")
while(c = sock.gets.chomp!)
  if(c == "LOGIN:#{client_name} OK")
    client_status = 'LOGEDIN'
  end
  if(client_status == 'LOGEDIN' && c == "END Game_Summary")
    sock.write("AGREE\n")
    puts "AGREE"
  end
  puts c
end
sock.close
