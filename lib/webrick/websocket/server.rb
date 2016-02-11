require 'digest/sha1'
require 'webrick/websocket/socket'
require 'webrick/websocket/servlet'

module WEBrick
  module Websocket
    ##
    # A HTTP Server with Websocket Support
    class HTTPServer < WEBrick::HTTPServer
      def initialize(*args, &block)
        super(*args, &block)
      end

      ## :nodoc:
      def service(req, res)
        if req.unparsed_uri == "*"
          if req.request_method == "OPTIONS"
            do_OPTIONS(req, res)
            raise HTTPStatus::OK
          end
          raise HTTPStatus::NotFound, "`#{req.unparsed_uri}' not found."
        end

        servlet, options, script_name, path_info = search_servlet(req.path)
        raise HTTPStatus::NotFound, "`#{req.path}' not found." unless servlet
        req.script_name = script_name
        req.path_info = path_info
        si = servlet.get_instance(self, *options)
        @logger.debug(format("%s is invoked.", si.class.name))
        if req['upgrade'] == 'websocket' && si.is_a?(Servlet)
          res.status = 101
          key = req['Sec-WebSocket-Key']
          res['Sec-WebSocket-Accept'] = Digest::SHA1.base64digest(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
          res['Sec-WebSocket-Protocol'] = si.select_protocol(req['Sec-WebSocket-Protocol']).split(/[ ,\t]+/) if req['Sec-WebSocket-Protocol']
          res['upgrade'] = 'websocket'
          res.setup_header
          res.instance_variable_get(:@header)['connection'] = 'upgrade'
          res.send_header(req.socket)
          sock = WEBrick::Websocket::Socket.new(req.socket, si, @logger)
          sock.run
          req.request_line = nil
        else
          si.service(req, res)
        end
      end
    end
  end
end