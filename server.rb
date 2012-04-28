#!/usr/bin/env ruby

$: << './lib'

require "rubygems"
require "bundler/setup"

require "eventmachine"
require "em-websocket"
require 'thin'
require 'sprockets'

require './app/bomb_app'
require 'game'
require 'client'

Thin::Logging.debug = true

EventMachine.run do
  server = Thin::Server.new('0.0.0.0', 3000) do
    map '/assets' do
      environment = Sprockets::Environment.new
      environment.append_path 'app/javascripts'
      environment.append_path 'app/stylesheets'
      run environment
    end

    map '/' do
      run BombApp
    end
  end
  server.threaded = true
  server.start

  game = Game.new
  EventMachine::WebSocket.start(host: '0.0.0.0', port: 3001) do |ws|
    ws.onopen do
      Client.new(game, ws)
    end
  end
end
