#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'

Mailman.config.poll_interval = 0



Mailman.config.imap = {
    server: $server,
    port: $port,
    ssl: true,
    username: $username,
    password: $password,
}

Mailman::Application.run do

  @@folders = []

  default do
    begin

      puts "+++++++++++++ folder +++++++++++++++++"

      p message['folder'].value
      @@folders << {name: message['folder'].value}

      puts "+++++++++++++ end folder +++++++++++++++++"

    rescue Exception => e
      Mailman.logger.error "Exception occurred while receiving message:\n#{message.subject} , #{message.from}"
      p "Error "
      Mailman.logger.error [e, *e.backtrace].join("\n")
      Kernel.exit

    end
  end
end

