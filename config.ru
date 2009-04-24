require 'rubygems'
require 'vendor/sinatra/lib/sinatra.rb'

disable :run
set :environment, :production
set :raise_errors, true
set :views, File.dirname(__FILE__) + '/views'
set :static, File.dirname(__FILE__) + '/static'
set :conf, File.dirname(__FILE__) + '/conf'
set :app_file, __FILE__

log = File.new("log/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require 'src/DB2WebCC.rb'
run Sinatra::Application