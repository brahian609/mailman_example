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

  default do
    begin

      case ENV['option']
        when 'unread'

          puts "++++++++++ mensajes no leidos ++++++++++++"

          p message['unread'].value
          @@unread = message['unread'].value

        when 'num_messages'

          puts "++++++++++ número total de mensajes ++++++++++++"

          p message['num_messages'].value
          @@num_messages = message['num_messages'].value

        else

          puts 'no hay una condición valida'

      end

    rescue Exception => e
      Mailman.logger.error "Exception occurred while receiving messages:\n#{message.subject} , #{message.from}"
      p "Error "
      Mailman.logger.error [e, *e.backtrace].join("\n")
      Kernel.exit

    end
  end
end

