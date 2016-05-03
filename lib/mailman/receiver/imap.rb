require 'net/imap'

module Mailman
  module Receiver
    # Receives messages using IMAP, and passes them to a {MessageProcessor}.
    class IMAP

      # @return [Net::IMAP] the IMAP connection
      attr_reader :connection

      # @param [Hash] options the receiver options
      # @option options [MessageProcessor] :processor the processor to pass new
      #   messages to
      # @option options [String] :server the server to connect to
      # @option options [Integer] :port the port to connect to
      # @option options [Boolean,Hash] :ssl if options is true, then an attempt will
      #   be made to use SSL (now TLS) to connect to the server. A Hash can be used
      #   to enable ssl and supply SSL context options.
      # @option options [Boolean] :starttls use STARTTLS command to start
      #   TLS session.
      # @option options [String] :username the username to authenticate with
      # @option options [String] :password the password to authenticate with
      # @option options [String] :folder the mail folder to search
      # @option options [Array] :done_flags the flags to add to messages that
      #   have been processed
      # @option options [String] :filter the search filter to use to select
      #   messages to process
      def initialize(options)
        @processor  = options[:processor]
        @server     = options[:server]
        @username   = options[:username]
        @password   = options[:password]
        @filter     = options[:filter] || 'UNSEEN'
        @done_flags = options[:done_flags] || [Net::IMAP::SEEN]
        @ssl        = options[:ssl] || false
        @starttls   = options[:starttls] || false
        @port       = options[:port] || (@ssl ? 993 : 143)
        @folder     = options[:folder] || "INBOX"
        @content    = options[:content] || "mail"

        if @starttls && @ssl
          raise StandardError.new("either specify ssl or starttls, not both")
        end
      end

      # Connects to the IMAP server.
      def connect
        tries ||= 5
        if @connection.nil? or @connection.disconnected?
          @connection = Net::IMAP.new(@server, port: @port, ssl: @ssl)
          if @starttls
            @connection.starttls
          end
          @connection.login(@username, @password)
        end
        @connection.select(@folder)
      rescue Net::IMAP::ByeResponseError, Net::IMAP::NoResponseError => e
        retry unless (tries -= 1).zero?
      end

      # Disconnects from the IMAP server.
      def disconnect
        return false if @connection.nil?
        @connection.logout
        @connection.disconnected? ? true : @connection.disconnect rescue nil
      end

      # Iterates through new messages, passing them to the processor, and
      # flagging them as done.
      def get_messages
        # status = @connection.status("inbox", ["MESSAGES", "RECENT"])
        # puts "++++++++++ status ++++++++++++"
        # puts status
        puts "++++++++++ no leidos ++++++++++++"
        count = @connection.search(["NOT", "SEEN"]).count
        p count
        puts "++++++++++ get messages ++++++++++++"
        @connection.search(@filter).slice($anterior..$siguiente).each do |message|
          # body = @connection.fetch(message, "RFC822")[0].attr["RFC822"]
          # @connection.sort(["DATE"], ["ALL"], "US-ASCII")
          if @content == "mail"
            body = @connection.fetch(message, "RFC822")[0].attr["RFC822"]
          else
            # body = @connection.fetch(message, ["BODY[HEADER.FIELDS (DATE FROM Message-ID SUBJECT)]"])[0].attr["BODY[HEADER.FIELDS (DATE FROM Message-ID SUBJECT)]"]
            envelope = @connection.fetch(message, "ENVELOPE")[0].attr["ENVELOPE"]
            body = {
                message_id: message,
                from: envelope.from[0].name,
                subject: envelope.subject,
                date: envelope.date,
            }
          end
          begin
            @processor.process(body)
          rescue StandardError => error
            Mailman.logger.error "Error encountered processing message: #{message.inspect}\n #{error.class.to_s}: #{error.message}\n #{error.backtrace.join("\n")}"
            next
          end
          # Mark All Unread Mail As Read
          # @connection.store(message, "+FLAGS", @done_flags)
        end
        # Clears messages that have the Deleted flag set
        # @connection.expunge
      end

      def get_folders

        begin

          folders = @connection.list('','*')
          folders.each do |fold|
            @processor.process({folder: fold.name})
          end

        rescue StandardError => error
          Mailman.logger.error "Error encountered processing folder: #{error.class.to_s}: #{error.message}\n #{error.backtrace.join("\n")}"
        end

      end

      def started?
        not (!@connection.nil? && @connection.disconnected?)
      end
    end
  end
end
