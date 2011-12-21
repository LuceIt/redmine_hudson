# $Id: 009_add_look_and_feel_to_hudson_settings.rb 403 2009-12-05 04:17:10Z toshiyuki.ando1971 $

class AddLookAndFeelToHudsonSettings < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :look_and_feel, :string, :default => "Hudson"
    HudsonSettings.update_all "look_and_feel = 'Hudson'"
  end

  def self.down
    remove_column :hudson_settings, :look_and_feel
  end
end
