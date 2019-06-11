ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'sinatra/base'

Bundler.require :default, ENV['RACK_ENV'].to_sym

class AppServer < Sinatra::Base
  get '/' do
    "mini_magick app using ImageMagick7: #{MiniMagick.imagemagick7?}"
  end

  run! if app_file == $0
end