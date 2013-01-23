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
require 'ronin/network/smtp'

module Ronin
  module Network
    module Mixins
      #
      # Adds SMTP convenience methods and connection parameters to a class.
      #
      # Defines the following parameters:
      #
      # * `host` (`String`) - SMTP host.
      # * `port` (`Integer`) - SMTP port.
      # * `smtp_login` (`String`) - SMTP authentication method.
      # * `smtp_user` (`String`) - SMTP user to login as.
      # * `smtp_password` (`String`) - SMTP password to login with.
      #
      module SMTP
        include Mixin, Network::SMTP

        # SMTP host
        parameter :host, type:        String,
                         description: 'SMTP host'

        # SMTP port
        parameter :port, type:        Integer,
                         description: 'SMTP port'

        # SMTP authentication method
        parameter :smtp_login, type:        String,
                               description: 'SMTP authentication method'

        # SMTP user to login as
        parameter :smtp_user, type:        String,
                              description: 'SMTP user to login as'

        # SMTP user to login with
        parameter :smtp_password, type:        String,
                                  description: 'SMTP password to login with'

        protected

        #
        # Creates a connection to the SMTP server. The `host`, `port`,
        # `smtp_login`, `smtp_user` and `smtp_password` parameters
        # will also be used to connect to the server.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Integer] :port (Ronin::Network::SMTP.default_port)
        #   The port to connect to.
        #
        # @option options [String] :helo
        #   The HELO domain.
        #
        # @option options [Symbol] :auth
        #   The type of authentication to use. Can be either `:login`,
        #   `:plain` or `:cram_md5`.
        #
        # @option options [String] :user
        #   The user-name to authenticate with.
        #
        # @option options [String] :password
        #   The password to authenticate with.
        #
        # @yield [session]
        #   If a block is given, it will be passed an SMTP session object.
        #
        # @yieldparam [Net::SMTP] session
        #   The SMTP session.
        #
        # @return [Net::SMTP]
        #   The SMTP session.
        #
        # @see Network::SMTP#smtp_connect
        #
        # @api public
        #
        def smtp_connect(options={},&block)
          print_info "Connecting to #{host_port} ..."

          return super(self.host,smtp_merge_options(options),&block)
        end

        #
        # Starts a session with the SMTP server. The `host`, `port`,
        # `smtp_login`, `smtp_user` and `smtp_password` parameters
        # will also be used to connect to the server.
        #
        # @yield [session]
        #   If a block is given, it will be passed an SMTP session object.
        #   After the block has returned, the session will be closed.
        #
        # @yieldparam [Net::SMTP] session
        #   The SMTP session.
        #
        # @see Network::SMTP#smtp_session
        #
        # @api public
        #
        def smtp_session(options={},&block)
          super(smtp_merge_options(options)) do |sess|
            yield sess if block_given?

            print_info "Logging out ..."
          end

          print_info "Disconnected to #{host_port}"
          return nil
        end

        private

        #
        # Merges the SMTP parameters into the options for {Network::SMTP}
        # methods.
        #
        # @param [Hash] options
        #   The original options.
        #
        # @return [Hash]
        #   The merged options.
        #
        # @since 0.4.0
        #
        # @api private
        #   
        def smtp_merge_options(options={})
          options[:port]     ||= self.port
          options[:login]    ||= self.smtp_login
          options[:user]     ||= self.smtp_user
          options[:password] ||= self.smtp_password

          return options
        end
      end
    end
  end
end
