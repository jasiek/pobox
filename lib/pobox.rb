require 'bundler'
Bundler.require

module Pobox
  def self.establish_connection
    ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: '/Users/jps/tmp/test.db')
  end

  def self.run_smtp_server
    establish_connection
    handler = -> (string) {
      Pobox::Message.parse(string) { |x| x.save! }
    }
    EM.run { EM.start_server '127.0.0.1', 25000, Pobox::SMTPServer, { handler: handler } }
  end

  def self.run_web_server
    establish_connection

    klass = Pobox::WebServer
    api = klass.new

    runner = Goliath::Runner.new(ARGV, api)
    runner.app = Goliath::Rack::Builder.build(klass, api)
    runner.run
  end
end

require 'active_record'

require 'lib/pobox/message'
require 'lib/pobox/smtp_server'
require 'lib/pobox/web_server'
