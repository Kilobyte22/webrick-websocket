#!/usr/bin/env ruby

require_relative '../lib/webrick/websocket'

serv = WEBrick::Websocket::HTTPServer.new(Port: 3000, DocumentRoot: File.dirname(__FILE__), Logger: (WEBrick::Log.new nil, WEBrick::BasicLog::DEBUG))

class SocketServlet < WEBrick::HTTPServlet::AbstractServlet
  def select_protocol(input)
    puts input.inspect
    input.first
  end

  def socket_text(sock, data)
    puts data
    sock.puts(data)
  end
end

serv.mount('/sock', SocketServlet)
serv.start