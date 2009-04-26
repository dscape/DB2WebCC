require 'rubygems'
require 'rack/cache'
require 'vendor/sinatra/lib/sinatra.rb'
require 'sha1'

APP_ENV = :development

use Rack::ShowExceptions unless APP_ENV == :production
use Rack::Reloader       unless APP_ENV == :production
use Rack::Cache do
  set :verbose, true
  set :metastore,   'heap:/'
  set :entitystore, 'heap:/'
end

disable :run
set :environment, APP_ENV
set :raise_errors, true
set :views, File.dirname(__FILE__) + '/views'
set :static, File.dirname(__FILE__) + '/static'
set :conf, File.dirname(__FILE__) + '/conf'
set :app_file, __FILE__
set :content_type_long, "application/xml"
set :templating_engine, "erb"  # available: erb, builder, haml, etc..

if APP_ENV == :production
  log_stdout = File.new("log/server.log", "a")
  log_stderr = File.new("log/messages.log", "a")
  STDOUT.reopen(log_stdout)
  STDERR.reopen(log_stderr)
end

# patch for ruby 1.8
if not Object.respond_to? :tap
  class Object
    def tap
      yield self
      self
    end
  end
end

require 'lib/db2webcc'
run Sinatra::Application