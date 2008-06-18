#!/usr/bin/env ruby -wKU

#this app requires sinatra: sudo gem install sinatra
#run this app, navigate to http://localhost:4567/all and see what happens!

require "rubygems" 
require "sinatra"
require File.dirname(__FILE__) + '/../lib/monomer'

configure do
            
  M = Monomer::Monome.new

end

get '/on' do
 M.all
 "all lights on! Try on/1/2 to turn on a particular light and /off to turn them all off again:<br/><code> #{ascii_status} </code>"
end

get '/on/:x/:y' do
  if(params['x'].to_i > 15 || params['y'].to_i > 7)
    'x/y coords out of range max is on/15/7'
  else
    M.led_on(params['x'].to_i, params['y'].to_i)
    "light turned on!: <br/><code> #{ascii_status} </code>"
  end
end

get '/off/:x/:y' do
  if(params['x'].to_i > 15 || params['y'].to_i > 7)
    'x/y coords out of range max is on/15/7'
  else
    M.led_off(params['x'].to_i, params['y'].to_i)
    "light turned off!: <br/><code> #{ascii_status} </code>"
  end
end

get '/view' do
  "<code> #{ascii_status} </code>"
end
 
get '/off' do
 M.clear
 "all lights off! Try on/1/2 to turn on a particular light and /on to turn them all on again:<br/><code> #{ascii_status} </code>"
end

def ascii_status
  M.ascii_status("<br>")
end

