require 'webrick/httprequest'
module WEBrick
  class HTTPRequest
    attr_reader :socket
    attr_writer :request_line
  end
end