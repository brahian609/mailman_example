class Attachment < ActiveRecord::Base
  attr_accessible :attached_file
  
  has_attached_file :attached_file, :preserve_files => false

  # Validate content type
  validates_attachment_content_type :attached_file, content_type: /\Aimage/
  # Validate filename
  validates_attachment_file_name :attached_file, matches: [/png\Z/, /jpe?g\Z/]
  # Explicitly do not validate
  do_not_validate_attachment_file_type :attached_file

end
