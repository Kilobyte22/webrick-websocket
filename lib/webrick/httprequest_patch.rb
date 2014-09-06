require 'webrick/httprequest'
module WEBrick
  class HTTPRequest
    attr_reader :socket
  end
end