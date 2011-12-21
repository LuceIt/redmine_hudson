# $Id: 008_add_get_build_details_to_hudson_settings.rb 403 2009-12-05 04:17:10Z toshiyuki.ando1971 $

class AddGetBuildDetailsToHudsonSettings < ActiveRecord::Migration
  def self.up
    add_column :hudson_settings, :get_build_details, :boolean, :default => true
  end

  def self.down
    remove_column :hudson_settings, :get_build_details
  end
end
