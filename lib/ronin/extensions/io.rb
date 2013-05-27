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

class IO

  #
  # read as much as possible until timeout
  #
  # @param [Double] timeout
  #   time to wait for timeout in second
  # 
  # @return [String] the read message
  #
  # @api public
  #
  def read_timeout(timeout=0.5)
    buffer = ""
  
    begin
      buffer << self.read_nonblock(1024)
    rescue IO::WaitReadable
      retry if IO.select([self], nil, nil, timeout)
    end

    buffer
  end

end
