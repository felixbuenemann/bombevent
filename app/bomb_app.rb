require 'sinatra/base'

class BombApp < Sinatra::Base
  get '/' do
    haml :index
  end
end
