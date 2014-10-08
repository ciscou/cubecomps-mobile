namespace :competitions do
  task archive_old: :environment do
    Competitions.new.archive_old!
  end
end
