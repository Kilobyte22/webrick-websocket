module WEBrick
  module Websocket
    ## :nodoc:
    class Frame
      @@ops_rev = {
          cont: 0,
          text: 1,
          binary: 2,
          close: 8,
          ping: 9,
          pong: 10
      }
      @@ops = {}
      @@ops_rev.each do |op, id|
        @@ops[id] = op
      end
      attr_reader :payload, :op
      def self.parse(socket, prev = nil)
        Frame.new(nil).parse(socket, prev)
      end

      def initialize(op, data = '')
        @op = op
        @payload = data
      end

      def parse(socket, prev)
        head = socket.read(1).unpack('C')[0]
        @fin = head & 0b10000000 > 0
        op = head & 0b00001111
        @op = @@ops[op]
        @op = prev if @op == :cont
        head = socket.read(1).unpack('C')[0]
        @masked = head & 0b10000000 > 0
        len = head & 0b01111111
        if len > 125
          long = len == 127
          len = socket.read(long ? 8 : 2).unpack(long ? 'Q' : 'S')[0]
        end
        @mask = socket.read(4).unpack('C4') if @masked
        @payload = socket.read(len)
        @payload = mask(@payload)
        self
      end

      def control?
        @@ops_rev[@op] > 7
      end
      def close?
        is(:close)
      end
      def binary?
        is(:binary)
      end
      def text?
        is(:text)
      end
      def ping?
        is(:ping)
      end
      def pong?
        is(:pong)
      end
      def fin?
        @fin
      end

      def write(sock)
        head = 0b10000000 + @@ops_rev[@op]
        puts head.to_s(2)
        sock.write([head].pack('C'))
        @len = @payload.length
        lendata = if @len > 125
          if @len > 65535
            [127, @len].pack('CQ')
          else
            [126, @len].pack('CS')
          end
        else
          [@len].pack('C')
        end
        sock.write(lendata)
        sock.write(@payload)
        sock.flush
      end

      private
      def is(what)
        @op == what
      end

      def mask(what)
        i = -1
        what.unpack('C*').map do |el|
          i += 1
          el ^ @mask[i % 4]
        end.pack('C*')
      end
    end
  end
end