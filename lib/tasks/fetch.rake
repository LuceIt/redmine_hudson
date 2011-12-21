# $Id: fetch.rake 318 2009-09-27 01:23:45Z toshiyuki.ando1971 $
desc 'Fetch buildresults from the Hudson'

namespace :redmine_hudson do
  task :fetch => :environment do
    Hudson.fetch
  end
end
