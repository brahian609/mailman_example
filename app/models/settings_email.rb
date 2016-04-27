class SettingsEmail < ActiveRecord::Base
  attr_accessible :username, :password, :server, :port

  validates :username, presence: true
  validates :password, presence: true
  validates :server, presence: true
  validates :port, presence: true

end
