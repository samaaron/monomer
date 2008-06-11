# gopt.rb: Written by Tadayoshi Funaba 2005
# $Id: gopt.rb,v 1.1 2005-07-09 07:44:04+09 tadf Exp $

require 'getoptlong'

module Gopt

  def gopt(opts)
    begin
      gol = GetoptLong.
	new(*opts.scan(/[^:]:{0,2}/).collect{|c|
	      ['-' + c[0,1],
		case c.size
		when 1; GetoptLong::NO_ARGUMENT
		when 2; GetoptLong::REQUIRED_ARGUMENT
		when 3; GetoptLong::OPTIONAL_ARGUMENT
		end]})
      gol.quiet = true
      val = {}
      gol.each{|opt, arg| val[opt[1,1].intern] = arg}
      val
    rescue
      nil
    end
  end

  module_function :gopt

end

if __FILE__ == $0
  p Gopt.gopt('ab:c::')
end
