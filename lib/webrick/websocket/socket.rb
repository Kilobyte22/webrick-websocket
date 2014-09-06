require 'webrick/websocket/frame'

module WEBrick
  module Websocket
    class Socket
      def initialize(sock, handler, logger)
        @prev = nil
        @sock = sock
        @handler = handler
        @open = true
        @logger = logger
        handle(:open)
      end

      def puts(data)
        send_frame(Frame.new(:text, data))
      end

      def close
        handle(:close)
        if @open
          @open = false
          send_frame(Frame.new(:close))
        end
      end

      def send_frame(frame)
        @logger.debug("Websocket Frame Sent: #{frame.op.to_s}(#{frame.payload.length} Bytes)")
        if frame.close? && @open
          close
        else
          frame.write(@sock)
        end
      end

      def run
        handle_packet while @open
      end

      private

      def handle_packet
        payload = ''
        while @open
          frame = read_frame
          @prev = frame.op
          if frame.control?
            case @prev
              when :ping
                send_frame(Frame.new(:pong))
              when :close
                @open = false
                close
            end
          else
            payload += frame.payload
            break if frame.fin?
          end
        end
        return unless @open
        handle(@prev, payload)
        handle(:data, @prev, payload)
      end

      def handle(op, *args)
        cb = 'socket_' + op.to_s
        @logger.debug("Websocket Callback: #{@handler.class.name}##{cb}")
        @handler.send(cb, self, *args) if @handler.respond_to?(cb)
      end

      def read_frame
        f = Frame.parse(@sock, @prev)
        @logger.debug("Websocket Frame Received: #{f.op.to_s}(#{f.payload.length} Bytes)")
        f
      end
    end
  end
end