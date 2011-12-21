# $Id: 003_add_auth_user_password.rb 175 2009-06-27 15:42:20Z toshiyuki.ando1971 $
class AddAuthUserPassword < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :auth_user, :string, :default => ''
    add_column :hudson_settings, :auth_password, :string, :default => ''
  end

  def self.down
    remove_column :hudson_settings, :auth_user
    remove_column :hudson_settings, :auth_password
  end
end
