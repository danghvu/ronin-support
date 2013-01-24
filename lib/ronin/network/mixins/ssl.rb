#
# Copyright (c) 2006-2012 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of Ronin Support.
#
# Ronin Support is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ronin Support is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ronin Support.  If not, see <http://www.gnu.org/licenses/>.
#

require 'ronin/network/mixins/mixin'
require 'ronin/network/ssl'

module Ronin
  module Network
    module Mixins
      #
      # Adds SSL convenience methods and connection parameters to a class.
      #
      # Defines the following parameters:
      #
      # * `host` (`String`) - SSL host.
      # * `port` (`Integer`) - SSL port.
      # * `local_host` (`String`) - SSL local host.
      # * `local_port` (`Integer`) - SSL local port.
      # * `server_host` (`String`) - SSL server host.
      # * `server_port` (`Integer`) - SSL server port.
      # * `ssl_verify` (`Symbol`) - SSL verify mode
      #   (`none`, `peer`, `fail_if_no_peer_cert`, `client_once`).
      # * `ssl_cert` (`String`) - Path to the `.crt` file.
      # * `ssl_key` (`String`) - Path to the `.key` file.
      #
      # @since 0.4.0
      #
      module SSL
        include Mixin, Network::SSL

        # SSL host
        parameter :host, type:        String,
                         description: 'SSL host'

        # SSL port
        parameter :port, type:        Integer,
                         description: 'SSL port'

        # SSL local host
        parameter :local_host, type:        String,
                               description: 'SSL local host'

        # SSL local port
        parameter :local_port, type:        Integer,
                               description: 'SSL local port'

        # SSL server host
        parameter :server_host, type:        String,
                                description: 'SSL server host'

        # SSL server port
        parameter :server_port, type:        Integer,
                                description: 'SSL server port'

        # SSL verify mode
        parameter :ssl_verify, type:        Symbol,
                               default:     :none,
                               description: 'SSL verify mode (none, peer, fail_if_no_peer_cert, client_once)'

        # SSL cert file
        parameter :ssl_cert, type:        String,
                             description: 'SSL cert file'

        # SSL key file
        parameter :ssl_key, type:        String,
                            description: 'SSL key file'

        protected

        #
        # Initiates an SSL session with an existing TCP socket.
        #
        # @param [TCPSocket] socket
        #   The existing TCP socket.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Symbol] :verify (#ssl_verify)
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert (#ssl_cert)
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key (#ssl_key)
        #   The path to the SSL `.key` file.
        #
        # @return [OpenSSL::SSL::SSLSocket]
        #   the new SSL Socket.
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_socket(socket,options={})
          options = {
            verify: self.ssl_verify,
            cert:   self.ssl_cert,
            key:    self.ssl_key
          }.merge(options)

          return super(socket,options)
        end

        #
        # Tests whether a remote SSLed TCP port is open.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :local_host
        #   The local host to bind to.
        #
        # @option options [Integer] :local_port
        #   The local port to bind to.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @option options [Integer] :timeout (5)
        #   The maximum time to attempt connecting.
        #
        # @return [Boolean, nil]
        #   Specifies whether the remote SSLed TCP port is open.
        #   If the connection was not accepted, `nil` will be returned.
        #
        # @example
        #   ssl_open?
        #
        # @example Using a timeout:
        #   ssl_open?(timeout: 5)
        #   # => nil
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_open?(host,port,options={})
          super(self.host,self.port,options)
        end

        #
        # Establishes a SSL connection.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:client_once`
        #   * `:fail_if_no_peer_cert`
        #
        # @option options [String] :cert
        #   The path to the SSL certificate.
        #
        # @option options [String] :key
        #   The path to the SSL key.
        #
        # @yield [ssl_socket]
        #   The given block will be passed the new SSL Socket.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] ssl_socket
        #   The new SSL Socket.
        #
        # @return [OpenSSL::SSL::SSLSocket]
        #   the new SSL Socket.
        #
        # @example
        #   socket = ssl_connect
        #
        # @see Network::SSL#ssl_connect
        #
        # @api public
        #
        def ssl_connect(options={},&block)
          options = options.merge(
            local_host: self.local_host,
            local_port: self.local_port
          )

          super(self.host,self.port,options,&block)
        end

        #
        # Creates a new temporary SSL connection.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :local_host
        #   The local host to bind to.
        #
        # @option options [Integer] :local_port
        #   The local port to bind to.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL certificate.
        #
        # @option options [String] :key
        #   The path to the SSL key.
        #
        # @yield [ssl_socket]
        #   The given block will be passed the temporary SSL Socket.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] ssl_socket
        #   The temporary SSL Socket.
        #
        # @return [nil]
        #
        # @example
        #   ssl_session do |socket|
        #     socket.write("GET / HTTP/1.1\n\r\n\r")
        #
        #     socket.each_line { |line| puts line }
        #   end
        #
        # @see Network::SSL#ssl_session
        #
        # @api public
        #
        def ssl_session(options={},&block)
          super(self.host,self.port,options,&block)
        end

        #
        # Creates a new SSL connection and sends the given data.
        #
        # @param [String] data
        #   The data to send through the connection.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :local_host
        #   The local host to bind to.
        #
        # @option options [Integer] :local_port
        #   The local port to bind to.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @yield [ssl_socket]
        #   The given block will be passed the newly created SSL Socket.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] ssl_socket
        #   The newly created SSL Socket.
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_connect_and_send(data,options={},&block)
          super(data,self.host,self.port,options,&block)
        end

        #
        # Reads the banner from the service running on the given host and port.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :local_host
        #   The local host to bind to.
        #
        # @option options [Integer] :local_port
        #   The local port to bind to.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @yield [banner]
        #   If a block is given, it will be passed the grabbed banner.
        #
        # @yieldparam [String] banner
        #   The grabbed banner.
        #
        # @return [String]
        #   The grabbed banner.
        #
        # @example
        #   ssl_banner
        #   # => "220 mx.google.com ESMTP c20sm3096959rvf.1"
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_banner(options={},&block)
          super(self.host,self.port,&block)
        end

        #
        # Connects to a specified host and port, sends the given data and then
        # closes the connection.
        #
        # @param [String] data
        #   The data to send through the connection.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [String] :local_host
        #   The local host to bind to.
        #
        # @option options [Integer] :local_port
        #   The local port to bind to.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @return [true]
        #   The data was successfully sent.
        #
        # @example
        #   buffer = "GET /#{'A' * 4096}\n\r"
        #   ssl_send(buffer)
        #   # => true
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_send(data,options={})
          super(data,self.host,self.port,options)
        end

        #
        # Creates a new SSL socket listening on a given host and port,
        # accepting clients in a loop.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Integer] :backlog (5)
        #   The maximum backlog of pending connections.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @yield [client]
        #   The given block will be passed the newly connected client.
        #   After the block has finished, the client will be closed.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] client
        #   A newly connected client.
        #
        # @return [nil]
        #
        # @example
        #   ssl_server_loop do |sock|
        #     sock.puts 'lol'
        #   end
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_server_loop(options={},&block)
          options = options.merge(
            port: self.server_port,
            host: self.server_host
          )

          return super(options,&block)
        end

        #
        # Creates a new SSL socket listening on a given host and port,
        # accepts only one client and then stops listening.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Integer] :backlog (5)
        #   The maximum backlog of pending connections.
        #
        # @option options [Symbol] :verify
        #   Specifies whether to verify the SSL certificate.
        #   May be one of the following:
        #
        #   * `:none`
        #   * `:peer`
        #   * `:fail_if_no_peer_cert`
        #   * `:client_once`
        #
        # @option options [String] :cert
        #   The path to the SSL `.crt` file.
        #
        # @option options [String] :key
        #   The path to the SSL `.key` file.
        #
        # @example
        #   ssl_accept(1337) do |client|
        #     client.puts 'lol'
        #   end
        #
        # @yield [client]
        #   The given block will be passed the newly connected client.
        #   After the block has finished, both the client and the server will be
        #   closed.
        #
        # @yieldparam [OpenSSL::SSL::SSLSocket] client
        #   The newly connected client.
        #
        # @return [nil]
        #
        # @example
        #   ssl_accept do |client|
        #     client.puts 'lol'
        #   end
        #
        # @api public
        #
        # @since 0.6.0
        #
        def ssl_accept(options={},&block)
          options = options.merge(
            port: self.server_port,
            host: self.server_host
          )

          return super(options,&block)
        end

      end
    end
  end
end
