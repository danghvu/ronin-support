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

require 'ronin/formatting/extensions/xml/string'
require 'ronin/formatting/extensions/text/string'

class String

  # JavaScript characters that must be back-slashed.
  JS_BACKSLASHED_CHARS = {
    "\\b"  => "\b",
    "\\t"  => "\t",
    "\\n"  => "\n",
    "\\f"  => "\f",
    "\\r"  => "\r",
    "\\\"" => "\"",
    "\\\\" => "\\"
  }

  #
  # HTML escapes the String.
  #
  # @return [String]
  #   The HTML escaped String.
  #
  # @example
  #   "one & two".html_escape
  #   # => "one &amp; two"
  #
  # @see http://rubydoc.info/stdlib/cgi/1.9.2/CGI.escapeHTML
  #
  # @since 0.2.0
  #
  # @see #xml_escape
  #
  # @api public
  #
  def html_escape
    xml_escape
  end

  #
  # Unescapes the HTML encoded String.
  #
  # @return [String]
  #   The unescaped String.
  #
  # @example
  #   "&lt;p&gt;one &lt;span&gt;two&lt;/span&gt;&lt;/p&gt;".html_unescape
  #   # => "<p>one <span>two</span></p>"
  #
  # @see http://rubydoc.info/stdlib/cgi/1.9.2/CGI.unescapeHTML
  #
  # @since 0.2.0
  #
  # @see #xml_unescape
  #
  # @api public
  #
  def html_unescape
    xml_unescape
  end

  #
  # Formats the chars in the String for HTML.
  #
  # @param [Hash] options
  #   Additional options for {#format_chars}.
  #
  # @return [String]
  #   The formatted HTML String.
  #
  # @example
  #   "abc".format_html
  #   # => "&#97;&#98;&#99;"
  #
  # @see Integer#format_html
  #
  # @since 0.2.0
  #
  # @see #format_xml
  #
  # @api public
  #
  def format_html(options={})
    format_xml(options)
  end

  #
  # Escapes a String for JavaScript.
  #
  # @param [Hash] options
  #   Additional options for {#format_chars}.
  #
  # @return [String]
  #   The JavaScript escaped String.
  #
  # @example
  #   "hello\nworld\n".js_escape
  #   # => "hello\\nworld\\n"
  #
  # @see Integer#js_escape
  #
  # @since 0.2.0
  #
  # @api public
  #
  def js_escape(options={})
    format_chars(options) { |c| c.ord.js_escape }
  end

  #
  # Unescapes a JavaScript escaped String.
  #
  # @return [String]
  #   The unescaped JavaScript String.
  #
  # @example
  #   "\\u0068\\u0065\\u006C\\u006C\\u006F world".js_unescape
  #   # => "hello world"
  #
  # @since 0.2.0
  #
  # @api public
  #
  def js_unescape
    unescaped = ''

    scan(/[\\%]u[0-9a-fA-F]{1,4}|[\\%][0-9a-fA-F]{1,2}|\\[btnfr"\\]|./) do |c|
      unescaped << JS_BACKSLASHED_CHARS.fetch(c) do
        if (c.start_with?("\\u") || c.start_with?("%u"))
          c[2..-1].to_i(16)
        elsif (c.start_with?("\\") || c.start_with?("%"))
          c[1..-1].to_i(16)
        else
          c
        end
      end
    end

    return unescaped
  end

  #
  # Escapes a String for JavaScript.
  #
  # @param [Hash] options
  #   Additional options for {#format_chars}.
  #
  # @return [String]
  #   The JavaScript escaped String.
  #
  # @example
  #   "hello".js_escape
  #   # => "\\u0068\\u0065\\u006C\\u006C\\u006F"
  #
  # @see Integer#js_escape
  #
  # @since 0.2.0
  #
  # @api public
  #
  def format_js(options={})
    format_chars(options) { |c| c.ord.format_js }
  end

end
