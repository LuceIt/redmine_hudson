# $Id: 001_create_hudson_settings.rb 175 2009-06-27 15:42:20Z toshiyuki.ando1971 $
class CreateHudsonSettings < ActiveRecord::Migration
  def self.up
    create_table :hudson_settings do |t|
      t.column :project_id, :int
      t.column :url, :string
      t.column :job_filter, :string
    end
  end

  def self.down
    drop_table :hudson_settings
  end
end
