#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'

#Mailman.config.logger = Logger.new("log/mailman.log")
Mailman.config.poll_interval = 0

$anterior = $anterior.blank? ? 1 : $anterior
$siguiente = $siguiente.blank? ? 3 : $siguiente

range_list_mail = ($anterior...$siguiente).to_a.join(',')
count_range = ($anterior...$siguiente).count


if count_range > 1
  content = 'mail_list'
else
  content = 'mail'
end



Mailman.config.imap = {
    server: $server,
    port: $port,
    ssl: true,
    #starttls: true,
    username: $username,
    password: $password,
    folder: $folder,
    filter: range_list_mail,
    # filter: ["FROM", "noreply@coursera.org"],
    content: content
}


cont = $anterior - 1

Mailman::Application.run do

  @@messages = []
  @@the_message_attachments = []

  default do
    begin

      cont += 1

      if count_range > 1

        p "#{cont} Nuevo mensaje"
        p message

        # @@messages += [{count_id: cont , from: message[0], subject: message[1]}]
        @@messages += [{count_id: cont , from: message.from, subject: message.subject}]


      else

        p "Detalles del mensaje"
        p message

        message_id = message.message_id

        to_list = ''
        to_list << message.to.join(',') if message.to.present?
        from_list = ''
        from_list << message.from.join(',') if message.from.present?
        cc_list = ''
        cc_list << message.cc.join(',') if message.cc.present?
        bcc_list = ''
        bcc_list << message.bcc.join(',') if message.bcc.present?
        fl = '0'

        if message.multipart?
          if message.html_part
            if message.html_part.charset.present?
              if message.html_part.body
                fl = '1'
                # to check if email has 7-bit Korean Charachter
                if message.html_part.charset == 'ISO-2022-KR'
                  the_message_html = message.html_part.body.decoded.encode('UTF-8', 'us-ascii', :invalid => :replace, :undef => :replace)
                else
                  the_message_html = message.html_part.body.decoded.encode('UTF-8', message.html_part.charset, :invalid => :replace, :undef => :replace)
                end
              end
            end
          end

          if message.text_part
            if message.text_part.body
              if message.text_part.charset.present?
                fl = '1'
                if message.text_part.charset == 'ISO-2022-KR'
                  the_message_text = message.text_part.body.decoded.encode('UTF-8', 'us-ascii', :invalid => :replace, :undef => :replace)
                else
                  the_message_text = message.text_part.body.decoded.encode('UTF-8', message.text_part.charset, :invalid => :replace, :undef => :replace)
                end
              end
            end
          end

          @@messages += [{count_id: cont , message_id: message_id, from: from_list, to: to_list, cc: cc_list, bcc: bcc_list, subject: message.subject, :html_body => the_message_html, text_body: the_message_text}]
          # p "Array de mensajes #{@@messages}"

          # em = Message.create(:message_id => message_id, :from => from_list, :to => to_list, :subject => message.subject, :html_body => the_message_html, :text_body => the_message_text)

          # to recieve the email attachments
          if count_range == 1

            message.attachments.each do |attachment|
              file = StringIO.new(attachment.decoded)
              file.class.class_eval { attr_accessor :original_filename, :content_type }
              file.original_filename = attachment.filename
              file.content_type = attachment.mime_type
              attachment = Attachment.new
              attachment.attached_file = file

              attachment.message_id = message_id
              # em.attachments << attachment
              attachment.save(:validate => false)
              @@the_message_attachments << attachment

            end
            # p "adjuntos #{@@the_message_attachments}"
          end

        else
          if message.text_part.present?
            if message.text_part.charset.present?
              fl = '1'
              if message.text_part.charset == 'ISO-2022-KR'
                the_message_text = message.text_part.body.decoded.encode('UTF-8', 'us-ascii', :invalid => :replace, :undef => :replace)
              else
                the_message_text = message.text_part.body.decoded.encode('UTF-8', message.text_part.charset, :invalid => :replace, :undef => :replace)
              end
            end
          end
          if message.html_part.present?
            if message.html_part.charset.present?
              fl = '1'
              if message.html_part.charset == 'ISO-2022-KR'
                the_message_html = message.html_part.body.decoded.encode('UTF-8′,us-ascii', :invalid => :replace, :undef => :replace)
              else
                the_message_html = message.html_part.body.decoded.encode('UTF-8', message.html_part.charset, :invalid => :replace, :undef => :replace)
              end
            end
          end

          if fl != '1'
            if message.body.present?
              if message.charset.present?
                if message.charset == 'ISO-2022-KR'
                  the_message_html = message.body.decoded.encode('UTF-8', 'us-ascii', :invalid => :replace, :undef => :replace)
                else
                  the_message_html = message.body.decoded.encode('UTF-8', message.charset, :invalid => :replace, :undef => :replace)
                end
              end
            end
          end
          # the_message_attachments = []
          @@messages += [{count_id: cont ,message_id: message_id, from: from_list, to: to_list, cc: cc_list, bcc: bcc_list, subject: message.subject, :html_body => the_message_html, text_body: the_message_text}]
          # em = Message.create(:message_id => message_id, :from => from_list, :to => to_list, :subject => message.subject, :html_body => the_message_html, :text_body => the_message_text)

        end

      end


    rescue Exception => e
      Mailman.logger.error "Exception occurred while receiving message:\n#{message.subject} , #{message.from}"
      p "Error "
      Mailman.logger.error [e, *e.backtrace].join("\n")
      Kernel.exit

    end
  end
end

