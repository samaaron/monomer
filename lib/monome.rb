$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'osc/gopt'
require 'osc/osc'

class Monome
  include OSC
  
  attr_accessor :listeners
  
  def initialize(monome=128, in_port=8000, out_port=8080)
    @monome = monome
    @client = SimpleClient.new('localhost', out_port)
    @server = SimpleServer.new(in_port)
    @max_x, @max_y = find_max_coords_from_monome_type
    #clear
    @led_toggle_status = Hash.new(false)  
    @listeners = []
  end
  
  def ascii_status(join_string="\n")
    result = ""
    (0..@max_y).each{|y| result << (0..@max_x).map{|x| @led_toggle_status[[x,y]] ? '* ' : '- '}.join + join_string}
    result
  end
  
  def on(x,y)
    @led_toggle_status[[x,y]] = true
    @client.send(Message.new('/test/led', nil, x,y, 1))
  end
  
  def off(x,y)
    @led_toggle_status[[x,y]] = false
    @client.send(Message.new('/test/led', nil, x,y, 0))
  end
  
  def toggle(x,y)
    @led_toggle_status[[x,y]] = !@led_toggle_status[[x,y]]
    @led_toggle_status[[x,y]] ? on(x,y) : off(x,y)
  end
  
  def clear
    (0..@max_x).each{|x| (0..@max_y).each{|y| off(x,y)}}
  end
  
  def all
    (0..@max_x).each{|x| (0..@max_y).each{|y| on(x,y)}}
  end
  
  def run
    @server.add_method(nil) do |mesg|
      x,y =  mesg.to_a[0..1]
      on_off = mesg.to_a[2] == 1 ? true : false
      @listeners.each {|listener| listener.call(x,y, on_off)}
    end
    @server.run
  end
  
  private
  
  def find_max_coords_from_monome_type
    case @monome
    when 128
      return [15,7]
    end
  end
  
end

