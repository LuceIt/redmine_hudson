# $Id: 005_add_caused_by_to_hudson_build.rb 201 2009-07-04 15:56:53Z toshiyuki.ando1971 $

class AddCausedByToHudsonBuild < ActiveRecord::Migration
  def self.up
    add_column :hudson_builds, :caused_by, :integer
  end

  def self.down
    remove_column :hudson_builds, :caused_by
  end
end
