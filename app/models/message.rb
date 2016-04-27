class Message < ActiveRecord::Base
  # attr_accessible :message_id, :from, :html_body, :subject, :text_body, :to
  attr_accessible :from, :html_body, :subject, :text_body, :to
end
