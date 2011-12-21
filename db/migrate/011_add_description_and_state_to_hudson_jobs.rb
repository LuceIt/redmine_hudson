# $Id: 011_add_description_and_state_to_hudson_jobs.rb 316 2009-09-26 15:17:42Z toshiyuki.ando1971 $

class AddDescriptionAndStateToHudsonJobs < ActiveRecord::Migration
  def self.up
    add_column :hudson_jobs, :description, :text
    add_column :hudson_jobs, :state, :string
  end

  def self.down
    remove_column :hudson_jobs, :description
    remove_column :hudson_jobs, :state
  end
end
