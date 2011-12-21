# $Id: 013_update_building.rb 338 2009-10-11 05:52:52Z toshiyuki.ando1971 $

require 'hudson_build'

class UpdateBuilding < ActiveRecord::Migration
  def self.up
    HudsonBuild.update_all "building = 'true'", "building = 't'"
    HudsonBuild.update_all "building = 'false'", "building = 'f'"
  end

  def self.down
    HudsonBuild.update_all "building = 't'", "building = 'true'"
    HudsonBuild.update_all "building = 'f'", "building = 'false'"
  end
end
