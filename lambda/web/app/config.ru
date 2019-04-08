require 'rack'
require 'rack/contrib'
require_relative './app'

set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "views") }
set :public_folder, Proc.new { File.join(root, 'public') }

run Sinatra::Application
