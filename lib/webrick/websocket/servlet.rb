module WEBrick
  module Websocket
    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      def select_protocol(input)
        input.first
      end
    end
  end
end