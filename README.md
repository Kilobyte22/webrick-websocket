# Webrick::Websocket

This gem allows you to use Websocket in your WEBrick web application.
First, create a HTTPServer with websocket support:

```ruby
require 'webrick/websocket'
server = WEBrick::Websocket::HTTPServer.new(Port: 8080, DocumentRoot: File.dirname(__FILE))
```

having that done do anything you would do with a regular WEBrick instance.
However, you can mount a Websocket Servlet.
 
```ruby
class MyServlet < WEBrick::Websocket::Servlet
  def select_protocol(available)
    # method optional, if missing, it will always select first protocol.
    # Will only be called if client actually requests a protocol
    available.include?('myprotocol') ? 'myprotocol' : nil
  end
  
  def socket_open(sock)
    # optional
    sock.puts 'Welcome' # send a text frame
  end
  
  def socket_close(sock)
    puts 'Poof. Socket gone.'
  end
  
  def socket_text(sock, text)
    puts "Client sent '#{text}'"
  end
end

server.mount('/websocket', MyServlet)
```

Aaaaand lets start the server

```ruby
server.start
```

Note, that it will always use the same servlet instance for a single socket and that each socket has its own servlet instance.
This means you can safely use instance variables inside the servlet to store the sockets state

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'webrick-websocket'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webrick-websocket

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/webrick-websocket/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
