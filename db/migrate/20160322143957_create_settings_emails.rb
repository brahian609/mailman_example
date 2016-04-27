class CreateSettingsEmails < ActiveRecord::Migration
  def change
    create_table :settings_emails do |t|
      t.text :username
      t.text :password
      t.string :server
      t.integer :port

      t.timestamps null: false
    end
  end
end
